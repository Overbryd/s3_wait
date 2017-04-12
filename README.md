# s3_wait

Wait for S3 keys, then issue a redirect to a presigned url if they exist.

![](https://cdn.shutterstock.com/shutterstock/videos/955447/thumb/1.jpg?i10c=img.resize(height:160))

## Pattern

In your application you create S3 objects in the **background** instead of the request-cycle.
A request triggers a **background job** and issues an S3 URL pointed to **s3_wait**.

**s3_wait** will then take the request, and wait until the S3 object becomes available.
Granted things go allright, **s3_wait** will eventually issue a redirect to the S3 object.

In addition to that, it will respect max redirect and response wait timeout settings of common browsers.

If the max redirect setting is reached, it will eventually respond with **504 Gateway Timeout**.

## Usage

    $ ruby server.rb

#### Settings available as environment variables

    AWS_ACCESS_KEY_ID=
    AWS_SECRET_ACCESS_KEY=
    AWS_S3_BUCKET=
    MAX_REDIRECTS=10
    WAIT_TIMEOUT=30
    PATH_PATTERN=.*

#### Endpoints

    GET /healthcheck  Healthcheck endpoint
    GET /*            the key to the S3 Object

## Implementation details

The server is designed to serve multiple requests at once, leveraging Celluiods actor pattern.
Waiting for S3 keys happens in the background.

