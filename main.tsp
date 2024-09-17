import "@typespec/http";
import "@typespec/versioning";

using TypeSpec.Http;
using TypeSpec.Versioning;

@service({
    title: "FOCUS",
})
@server("http://focus.test.win-9.kr/api", "Test server endpoint")
@versioned(Versions)
namespace Focus;

enum Versions {
    alpha: "0.1.0",
}

scalar binary extends bytes;

model RecordListResponse<Record> {
    ...OkResponse;
    ...Body<Record[]>;
}

model RecordResponse<Record> {
    ...OkResponse;
    ...Body<Record>;
}

model RecordCreatedResponse<Record> {
    ...CreatedResponse;
    ...Body<Record>;
}

model RecordAcceptedResponse<Record> {
    ...AcceptedResponse;
    ...Body<Record>;
}

model MultipartRequest<Record> {
    record: Record;
    file?: binary;
}

model RecordErrorResponse {
    ...BadRequestResponse;
    ...Body<ValidationError>;
}

model RecordNotFoundResponse {
    ...NotFoundResponse;
    ...Body<NotFoundError>;
}

model RecordUnauthorizedResponse {
    ...UnauthorizedResponse;
    ...Body<UnauthorizedError>;
}

model RecordNoContentResponse {
    ...NoContentResponse;
}

@route("/books")
namespace Books {
    model BookMutation {
        title: string;
        author: string;
    }

    model BookRecord extends BookMutation {
        id: int32;
        coverImageUrl?: string;
    }

    model BookMultipartRequest is MultipartRequest<BookMutation>;

    @get
    @useAuth(BearerAuth)
    op listBooks(): RecordListResponse<BookRecord> | RecordUnauthorizedResponse;

    @get
    @useAuth(BearerAuth)
    op getBook(
        @path bookId: int32,
    ): RecordResponse<BookRecord> | RecordNotFoundResponse | RecordUnauthorizedResponse;

    @post
    @useAuth(BearerAuth)
    op createBook(@body book: BookMultipartRequest):
        | RecordCreatedResponse<BookRecord>
        | RecordAcceptedResponse<BookRecord>
        | RecordErrorResponse
        | RecordUnauthorizedResponse;

    @put
    @useAuth(BearerAuth)
    op updateBook(@path bookId: int32, @body book: BookMultipartRequest):
        | RecordResponse<BookRecord>
        | RecordErrorResponse
        | RecordNotFoundResponse
        | RecordUnauthorizedResponse
        | InternalServerErrorResponse;

    @delete
    @useAuth(BearerAuth)
    op deleteBook(
        @path bookId: int32,
    ): RecordNoContentResponse | RecordUnauthorizedResponse;
}

@route("/bookmarks")
namespace Bookmarks {
    model BookmarkMutation {
        bookId: int32;
        content: string;
        page: int32;
    }

    model BookmarkRecord extends BookmarkMutation {
        id: int32;
        date: string; // yyyy-MM-dd
        thumbnailImageUrl?: string;
    }

    model BookmarkMultipartRequest is MultipartRequest<BookmarkRecord>;

    @get
    @useAuth(BearerAuth)
    op listBookmarks(
    ): RecordListResponse<BookmarkRecord> | RecordUnauthorizedResponse;

    @get
    @useAuth(BearerAuth)
    op getBookmark(
        @path bookmarkId: int32,
    ): RecordResponse<BookmarkRecord> | RecordNotFoundResponse | RecordUnauthorizedResponse;

    @post
    @useAuth(BearerAuth)
    op createBookmark(@body bookmark: BookmarkMultipartRequest):
        | RecordCreatedResponse<BookmarkRecord>
        | RecordAcceptedResponse<BookmarkRecord>
        | RecordErrorResponse
        | RecordUnauthorizedResponse;

    @put
    @useAuth(BearerAuth)
    op updateBookmark(
        @path bookmarkId: int32,
        @body bookmark: BookmarkMultipartRequest,
    ):
        | RecordResponse<BookmarkRecord>
        | RecordErrorResponse
        | RecordNotFoundResponse
        | RecordUnauthorizedResponse
        | InternalServerErrorResponse;

    @delete
    @useAuth(BearerAuth)
    op deleteBookmark(
        @path bookmarkId: int32,
    ): RecordNoContentResponse | RecordUnauthorizedResponse;
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
