import random
from typing import Any

from src.service.quotes import QuoteNotFoundError, QuotesRepository


class DynamoQuotesRepository(QuotesRepository):
    def __init__(
        self,
        dynamodb: Any,
        table_name: str | None,
    ):
        if not table_name:
            raise ValueError("QUOTES_TABLE_NAME is not configured")

        self.table = dynamodb.Table(table_name)

    def random(self) -> str:
        metadata_response = self.table.get_item(
            Key={"id": 0},
            ProjectionExpression="#count",
            ExpressionAttributeNames={"#count": "count"},
            ConsistentRead=True,
        )
        metadata = metadata_response.get("Item")
        if metadata is None or int(metadata.get("count", 0)) < 1:
            raise QuoteNotFoundError("Quote metadata was not found")

        quote_id = random.randint(1, int(metadata["count"]))
        response = self.table.get_item(
            Key={"id": quote_id},
            ProjectionExpression="#quote",
            ExpressionAttributeNames={"#quote": "quote"},
            ConsistentRead=True,
        )

        item = response.get("Item")
        if item is None:
            raise QuoteNotFoundError(f"Quote with id={quote_id} was not found")

        return item["quote"]
