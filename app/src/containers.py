import boto3
from dependency_injector import containers, providers

from src.repository.quotes import DynamoQuotesRepository, LocalQuotesRepository
from src.service.quotes import QuotesRepository, QuotesService


def create_quotes_repository(table_name: str | None) -> QuotesRepository:
    if not table_name:
        return LocalQuotesRepository()
    return DynamoQuotesRepository(boto3.resource("dynamodb"), table_name)


class Container(containers.DeclarativeContainer):
    wiring_config = containers.WiringConfiguration(modules=[".router"])

    config = providers.Configuration()

    quotes_repository = providers.Singleton(
        create_quotes_repository,
        table_name=config.quotes_table_name,
    )
    quotes_service = providers.Factory(
        QuotesService,
        repo=quotes_repository,
    )
