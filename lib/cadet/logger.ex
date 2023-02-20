defmodule Cadet.Logger do
  alias Logger.Formatter
  @behaviour :gen_event
  import Nostrum.Struct.Embed

  defstruct [
    :level,
    :channel_id,
    :time_zone,
    format: "$metadata\n```$message```",
  ]

  @type config :: %__MODULE__{
    level: Logger.level(),
    channel_id: Nostrum.Snowflake.t(),
    time_zone: String.t(),
    format: String.t()
  }

  @colors [
    debug: 0x3a96dd,
    info: 0xffffff,
    warn: 0xa2734c,
    error: 0xc21a23
  ]

  def init({__MODULE__, opts}), do: {:ok, configure(%__MODULE__{}, opts)}
  def init(_), do: {:ok, configure(%__MODULE__{}, [])}

  def handle_call({:configure, opts}, state), do: {:ok, :ok, configure(state, opts)}

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({_level, _gl, _lg}, %{channel_id: nil} = state), do: {:ok, state}
  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    if meet_level?(level, min_level) do
      {:ok, log_event(level, msg, ts, md, state)}
    else
      {:ok, state}
    end
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

  defp log_event(_level, _msg, _ts, _md, %{channel_id: nil} = state), do: {:ok, state}
  defp log_event(level, msg, ts, md, %{channel_id: channel_id, time_zone: tz, format: format} = _state) do
    embed = %Nostrum.Struct.Embed{}
      |> put_title(String.capitalize(Atom.to_string(level)))
      |> put_color(Keyword.get(@colors, level, 0xffffff))
      |> put_description(gen_desc(ts, tz, IO.chardata_to_string(Formatter.format(format, level, msg, ts, md))))

    Nostrum.Api.create_message(channel_id, embeds: [embed])
  end

  defp gen_desc({{yr, mt, dy}, {hr, mn, sd, mi}}, tz, msg) do
    time = NaiveDateTime.new!(yr, mt, dy, hr, mn, sd, mi)
      |> DateTime.from_naive!(tz, Tz.TimeZoneDatabase)
      |> DateTime.to_unix()

    """
    <t:#{time}:F>
    #{msg}
    """
  end

  defp configure(state, opts) do
    opts = Application.get_env(:logger, __MODULE__, [])
      |> Keyword.merge(opts)
    Application.put_env(:logger, __MODULE__, opts)

    level = Keyword.get(opts, :level)
    channel_id = Keyword.get(opts, :channel_id)
    time_zone = Keyword.get(opts, :time_zone)
    format = Formatter.compile(Keyword.get(opts, :format))

    %__MODULE__{
      state
      | level: level,
        channel_id: channel_id,
        time_zone: time_zone,
        format: format
    }
  end

  defp meet_level?(_lvl, nil), do: true
  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end
end
