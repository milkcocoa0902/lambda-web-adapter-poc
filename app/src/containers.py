import boto3
from dependency_injector import containers, providers

from src.repository.quotes import DynamoQuotesRepository
from src.service.quotes import QuotesService


class Container(containers.DeclarativeContainer):
    wiring_config = containers.WiringConfiguration(modules=[".router"])

    config = providers.Configuration()

    dynamodb = providers.Singleton(boto3.resource, service_name="dynamodb")
    quotes_repository = providers.Factory(
        DynamoQuotesRepository,
        dynamodb=dynamodb,
        table_name=config.quotes_table_name,
    )
    quotes_service = providers.Factory(
        QuotesService,
        repo=quotes_repository,
    )
