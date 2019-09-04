
"""
    TrelloCred(;api_key, api_token)

A credentials and identity object for Trello.
If the api_key or api_token are not provided, they will be read from
the `TRELLO_API_KEY` and `TRELLO_API_TOKEN` environment variables respectively.

Follow the instructions in the [Trello Documentation](https://developers.trello.com/docs/api-introduction#section--a-name-auth-authentication-and-authorization-a-) to aquire your credentials.
"""
struct TrelloCred
    api_key::String
    api_token::String
end

function TrelloCred(;api_key=ENV["TRELLO_API_KEY"], api_token=ENV["TRELLO_API_TOKEN"])
    return TrelloCred(api_key, api_token)
end

Base.show(io::IO, ::TrelloCred) = println(io, "TrelloCred(<secrets>)")


