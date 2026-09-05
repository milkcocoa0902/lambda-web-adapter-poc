import asyncio
from collections.abc import AsyncIterator
from typing import Annotated

from dependency_injector.wiring import Provide, inject
from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse

from .containers import Container
from .service.quotes import QuotesService

router = APIRouter()


@router.get("/")
def health() -> dict[str, str]:
    return {"status": "ok"}


@router.get("/quotes/random")
@inject
def random_quote(
    service: Annotated[
        QuotesService,
        Depends(Provide[Container.quotes_service]),
    ],
) -> dict[str, str]:
    return {"quote": service.random()}


@router.get("/quotes/random/stream", response_class=StreamingResponse)
@inject
def stream_random_quote(
    service: Annotated[
        QuotesService,
        Depends(Provide[Container.quotes_service]),
    ],
) -> StreamingResponse:
    quote = service.random()

    async def stream_characters() -> AsyncIterator[str]:
        for character in quote:
            yield character
            await asyncio.sleep(0.1)

    return StreamingResponse(
        stream_characters(),
        media_type="text/plain",
        headers={"X-Content-Type-Options": "nosniff"},
    )
