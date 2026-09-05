from abc import ABC, abstractmethod


class QuoteNotFoundError(Exception):
    """Raised when quote data cannot be found."""


class QuotesRepository(ABC):
    @abstractmethod
    def random(self) -> str:
        pass


class QuotesService:
    def __init__(self, repo: QuotesRepository):
        self.quotes_repository = repo

    def random(self) -> str:
        return self.quotes_repository.random()
