FROM public.ecr.aws/awsguru/aws-lambda-adapter:1.0.1 AS lambda-adapter
FROM ghcr.io/astral-sh/uv:0.11.19 AS uv
FROM public.ecr.aws/docker/library/python:3.14-slim

COPY --from=lambda-adapter /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=uv /uv /uvx /bin/

ENV PATH="/app/.venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    AWS_LWA_PORT=8080 \
    AWS_LWA_READINESS_CHECK_PATH=/ \
    AWS_LWA_READINESS_CHECK_HEALTHY_STATUS=200-299 \
    AWS_LWA_INVOKE_MODE=response_stream

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-dev --no-install-project

COPY src ./src

EXPOSE 8080

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
