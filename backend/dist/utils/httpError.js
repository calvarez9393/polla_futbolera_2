export class HttpError extends Error {
    statusCode;
    code;
    constructor(message, statusCode, code) {
        super(message);
        this.statusCode = statusCode;
        this.code = code;
        this.name = "HttpError";
    }
}
