defmodule AutojoinExample.Repo do
  use Ecto.Repo,
    otp_app: :autojoin_example,
    adapter: Ecto.Adapters.Postgres
end
