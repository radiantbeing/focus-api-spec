import "@typespec/http";

using TypeSpec.Http;
@service({
    title: "FOCUS",
})
@server("http://focus.test.win-9.kr/api", "Test server endpoint")
namespace Focus;

scalar binary extends bytes;

model BookMutation {
    title?: string;
    author?: string;
}

model BookRecord extends BookMutation {
    id: int32;
    coverImageUrl?: string;
}

model MultipartRequest<Item> {
    item: Item;
    file?: binary;
}

model BookListResponse {
    ...OkResponse;
    ...Body<BookRecord[]>;
}

model BookResponse {
    ...OkResponse;
    ...Body<BookRecord>;
}

model BookCreatedResponse {
    ...CreatedResponse;
    ...Body<BookRecord>;
}

model BookAcceptedResponse {
    ...AcceptedResponse;
    ...Body<BookRecord>;
}

model BookErrorResponse {
    ...BadRequestResponse;
    ...Body<ValidationError>;
}

model BookNotFoundResponse {
    ...NotFoundResponse;
    ...Body<NotFoundError>;
}

model BookUnauthorizedResponse {
    ...UnauthorizedResponse;
    ...Body<UnauthorizedError>;
}

model BookNoContentResponse {
    ...NoContentResponse;
}

@route("/books")
namespace Books {
    @get
    @useAuth(BearerAuth)
    op listBooks(): BookListResponse | BookUnauthorizedResponse;

    @get
    @useAuth(BearerAuth)
    op getPet(
        @path bookId: int32,
    ): BookResponse | BookNotFoundResponse | BookUnauthorizedResponse;

    @post
    @useAuth(BearerAuth)
    op createBook(@body book: MultipartRequest<BookMutation>):
        | BookCreatedResponse
        | BookAcceptedResponse
        | BookErrorResponse
        | BookUnauthorizedResponse;

    @put
    @useAuth(BearerAuth)
    op updateBook(
        @path bookId: int32,
        @body book: MultipartRequest<BookMutation>,
    ):
        | BookResponse
        | BookErrorResponse
        | BookNotFoundResponse
        | BookUnauthorizedResponse
        | InternalServerErrorResponse;

    @delete
    @useAuth(BearerAuth)
    op deleteBook(
        @path bookId: int32,
    ): BookNoContentResponse | BookUnauthorizedResponse;
}

@error
model NotFoundError {
    code: "NOT_FOUND";
    message: string;
}

@error
model ValidationError {
    code: "VALIDATION_ERROR";
    message: string;
    details: string[];
}

@error
model UnauthorizedError {
    code: "UNAUTHORIZED";
    message: string;
}

@error
model InternalServerError {
    code: "INTERNAL_SERVER_ERROR";
    message: string;
}

model InternalServerErrorResponse {
    @statusCode statusCode: 500;
    @body error: InternalServerError;
}
