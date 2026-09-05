from fastapi import FastAPI

from src.containers import Container
from src.middleware.exceptions import ExceptionHandlingMiddleware
from src.router import router

app = FastAPI()
app.add_middleware(ExceptionHandlingMiddleware)

container = Container()
container.config.quotes_table_name.from_env("QUOTES_TABLE_NAME")
app.container = container

app.include_router(router)
