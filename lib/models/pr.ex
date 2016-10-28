defmodule SlackCoder.Models.PR do
  use SlackCoder.Web, :model

  schema "prs" do
    field :owner, :string
    field :repo, :string
    field :branch, :string
    field :fork, :boolean
    # Stale PR checking
    field :latest_comment, Timex.Ecto.DateTime
    field :latest_comment_url, :string
    field :notifications, SlackCoder.Models.Types.StringList, virtual: true, default: []
    field :opened_at, Timex.Ecto.DateTime
    field :closed_at, Timex.Ecto.DateTime
    field :merged_at, Timex.Ecto.DateTime
    field :backoff, :integer, default: Application.get_env(:slack_coder, :pr_backoff_start, 1)
    # Used in view
    field :title, :string
    field :number, :integer
    field :html_url, :string
    field :mergeable, :boolean
    field :github_user, :string
    field :github_user_avatar, :string
    # Build status info
    field :sha, :string
    field :build_status, :string
    field :analysis_status, :string
    field :build_url, :string
    field :analysis_url, :string

    belongs_to :user, SlackCoder.Models.User

    timestamps
  end

  @required_fields ~w(owner repo branch github_user title number html_url opened_at)
  @optional_fields ~w(latest_comment latest_comment_url notifications backoff merged_at closed_at mergeable
                      github_user_avatar fork sha build_status analysis_status build_url analysis_url user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:commits)
  end

  def reg_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def active(query \\ __MODULE__) do
    from pr in query, where: is_nil(pr.closed_at) and is_nil(pr.merged_at)
  end

  def by_number(query \\ __MODULE__, number) do
    from pr in query, where: pr.number == ^number
  end

end
