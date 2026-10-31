# Lambda Web Adapter + FastAPI PoC

通常のFastAPIをLambda固有handlerなしでローカルとLambdaで動かす技術検証です。

## 構成

- Local: Uvicorn → FastAPI → 同梱の `app/data/quotes.json`
- AWS: CloudFront + WAF → OAC → Function URL → LWA → Uvicorn → FastAPI → DynamoDB
- `GET /`: readiness、`{"status":"ok"}`
- `GET /quotes/random`: `{"quote":"..."}`
- `GET /quotes/random/stream`: text/plain、0.1秒間隔で文字を送信
- `GET /docs`: Swagger UI

`QUOTES_TABLE_NAME`未設定時はJSONを読み、AWSクライアントを作成しません。設定時はDynamoDBを使います。TerraformはLambdaにテーブル名を設定します。

LWA 1.0.1、Python 3.14、ポート8080、readinessは`/`の200–299、invoke modeは`response_stream`です。Lambdaは512MB・30秒・x86_64です。

## ローカル実行

リポジトリルートから実行します。AWS認証・DynamoDB・seedは不要です。

```bash
cd app
uv sync --locked
env -u QUOTES_TABLE_NAME uv run uvicorn src.main:app --host 0.0.0.0 --port 8080
```

別ターミナルで確認します。

```bash
curl http://localhost:8080/
curl http://localhost:8080/quotes/random
curl -N http://localhost:8080/quotes/random/stream
```

Dockerもリポジトリルートから実行します。同じJSONをイメージへ同梱します。

```bash
docker build --platform linux/amd64 -t lwa-fastapi ./app
docker run --rm -p 8080:8080 lwa-fastapi
```

## AWSへのデプロイ

Terraform、Docker、AWS CLI、jqとデプロイ先へのAWS認証が必要です。通常リソースとWAFはすべて`us-east-1`です。

```bash
terraform -chdir=terraform/01_bootstrap init
terraform -chdir=terraform/01_bootstrap plan -out=tfplan
terraform -chdir=terraform/01_bootstrap apply tfplan
./script/push_image.sh v1
```

スクリプトが出力したURIを次の変数へ設定します。ECRタグはimmutableなので、更新時は新しいタグを使います。`lwa_image`はタグURIとdigest URIを受け付けます。

```bash
LWA_IMAGE_URI='出力されたECRイメージURI'
terraform -chdir=terraform/02_application init
terraform -chdir=terraform/02_application plan -var="lwa_image=${LWA_IMAGE_URI}" -out=tfplan
terraform -chdir=terraform/02_application apply tfplan
./script/seed_quotes.sh
```

seedは格言50件と件数メタデータをDynamoDBに書き込みます。Lambdaの読み取り権限は対象テーブルのGetItemだけです。テーブルにPITR・削除保護は設定していません。

## AWSでの確認

```bash
DISTRIBUTION_DOMAIN=$(terraform -chdir=terraform/02_application output -raw cloudfront_distribution_url)
curl "https://${DISTRIBUTION_DOMAIN}/quotes/random"
curl -N "https://${DISTRIBUTION_DOMAIN}/quotes/random/stream"
```


## 検証と範囲

```bash
cd app
uv run pytest -q
uv run ruff check .
cd ..
terraform -chdir=terraform/02_application fmt -check waf.tf
terraform -chdir=terraform/01_bootstrap validate
terraform -chdir=terraform/02_application validate
```

