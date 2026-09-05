from unittest.mock import patch

from dependency_injector import providers
from fastapi.testclient import TestClient

from src.main import app
from src.repository.quotes import DynamoQuotesRepository
from src.service.quotes import QuoteNotFoundError, QuotesRepository


class TestQuotesRepository(QuotesRepository):
    def random(self) -> str:
        return "test quote"


class MissingQuoteRepository(QuotesRepository):
    def random(self) -> str:
        raise QuoteNotFoundError("Quote metadata was not found")


class FailingQuotesRepository(QuotesRepository):
    def random(self) -> str:
        raise RuntimeError("internal database detail")


def test_repository_can_be_overridden() -> None:
    test_repository = providers.Factory(TestQuotesRepository)

    with app.container.quotes_repository.override(test_repository):
        assert app.container.quotes_service().random() == "test quote"


def test_quote_endpoints() -> None:
    test_repository = providers.Factory(TestQuotesRepository)

    with (
        app.container.quotes_repository.override(test_repository),
        TestClient(app, backend_options={"use_uvloop": True}) as client,
    ):
        health_response = client.get("/")
        quote_response = client.get("/quotes/random")
        stream_response = client.get("/quotes/random/stream")

    assert health_response.status_code == 200
    assert health_response.json() == {"status": "ok"}
    assert quote_response.status_code == 200
    assert quote_response.json() == {"quote": "test quote"}
    assert stream_response.status_code == 200
    assert stream_response.text == "test quote"


def test_exception_middleware_returns_not_found_for_missing_quote() -> None:
    test_repository = providers.Factory(MissingQuoteRepository)

    with (
        app.container.quotes_repository.override(test_repository),
        TestClient(app, backend_options={"use_uvloop": True}) as client,
    ):
        response = client.get("/quotes/random")

    assert response.status_code == 404
    assert response.json() == {"detail": "Quote metadata was not found"}


def test_exception_middleware_hides_unhandled_exception_details() -> None:
    test_repository = providers.Factory(FailingQuotesRepository)

    with (
        app.container.quotes_repository.override(test_repository),
        TestClient(app, backend_options={"use_uvloop": True}) as client,
    ):
        response = client.get("/quotes/random")

    assert response.status_code == 500
    assert response.json() == {"detail": "Internal Server Error"}


class FakeTable:
    def __init__(self) -> None:
        self.get_item_options: list[dict] = []
        self.responses = iter(
            [
                {"Item": {"count": 3}},
                {"Item": {"quote": "second quote"}},
            ]
        )

    def get_item(self, **options: object) -> dict:
        self.get_item_options.append(options)
        return next(self.responses)


class FakeDynamoDB:
    def __init__(self, table: FakeTable) -> None:
        self.table = table
        self.requested_table_name: str | None = None

    def Table(self, table_name: str) -> FakeTable:
        self.requested_table_name = table_name
        return self.table


def test_dynamodb_repository_reads_random_quote_by_id() -> None:
    table = FakeTable()
    dynamodb = FakeDynamoDB(table)
    repository = DynamoQuotesRepository(dynamodb, "quotes-table")

    with patch("src.repository.quotes.random.randint", return_value=2):
        assert repository.random() == "second quote"

    assert dynamodb.requested_table_name == "quotes-table"
    assert table.get_item_options[0]["Key"] == {"id": 0}
    assert table.get_item_options[1]["Key"] == {"id": 2}
