import logging

from starlette.responses import JSONResponse
from starlette.types import ASGIApp, Message, Receive, Scope, Send

from src.service.quotes import QuoteNotFoundError

logger = logging.getLogger(__name__)


class ExceptionHandlingMiddleware:
    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    async def __call__(
        self,
        scope: Scope,
        receive: Receive,
        send: Send,
    ) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        response_started = False

        async def send_with_state(message: Message) -> None:
            nonlocal response_started
            if message["type"] == "http.response.start":
                response_started = True
            await send(message)

        try:
            await self.app(scope, receive, send_with_state)
        except QuoteNotFoundError as error:
            if response_started:
                raise

            response = JSONResponse(
                status_code=404,
                content={"detail": str(error)},
            )
            await response(scope, receive, send)
        except Exception:
            logger.exception(
                "Unhandled exception while processing %s %s",
                scope.get("method", "UNKNOWN"),
                scope.get("path", ""),
            )
            if response_started:
                raise

            response = JSONResponse(
                status_code=500,
                content={"detail": "Internal Server Error"},
            )
            await response(scope, receive, send)
