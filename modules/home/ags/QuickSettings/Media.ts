import { MprisPlayer } from "types/service/mpris"

const mpris = await Service.import("mpris")
const players = mpris.bind("players")

const FALLBACK_ICON = "audio-x-generic-symbolic"
const PLAY_ICON = "media-playback-start-symbolic"
const PAUSE_ICON = "media-playback-pause-symbolic"
const PREV_ICON = "media-skip-backward-symbolic"
const NEXT_ICON = "media-skip-forward-symbolic"

function formatPlayerPosition(length: number): string {
  const min = Math.floor(length / 60)
  const sec = Math.floor(length % 60)
  const sec0 = sec < 10 ? "0" : ""
  return `${min}:${sec0}${sec}`
}

const Player = (player: MprisPlayer) => {

  const CoverImage = Widget.Box({
    class_name: "img",
    vpack: "start",
    css: Utils.merge([
      player.bind("cover_path"),
      player.bind("track_cover_url"),
    ], (path, url) => `
        background-image: url('${path || url}');
    `),
  })

  const Title = Widget.Label({
    class_name: "title",
    max_width_chars: 20,
    truncate: "end",
    hpack: "start",
    label: player.bind("track_title"),
  })

  const Artist = Widget.Label({
    class_name: "artist",
    max_width_chars: 20,
    truncate: "end",
    hpack: "start",
    label: player.bind("track_artists").transform(a => a.join(", ")),
  })

  const PositionSlider = Widget.Slider({
    class_name: "position",
    draw_value: false,
    on_change: ({ value }) => player.position = value * player.length,
    setup: self => {
      const update = () => {
        const { length, position } = player
        self.visible = length > 0
        self.value = length > 0 ? position / length : 0
      }
      self.hook(player, update)
      self.hook(player, update, "position")
      self.poll(1000, update)
    },
  })

  const PositionLabel = Widget.Label({
    class_name: "position",
    hpack: "start",
    setup: self => {
      const update = (_: unknown, time?: number) => {
        self.label = formatPlayerPosition(time || player.position)
        self.visible = player.length > 0
      }

      self.hook(player, update, "position")
      self.poll(1000, update)
    }
  })

  const LengthLabel = Widget.Label({
    class_name: "length",
    hpack: "end",
    visible: player.bind("length").transform(l => l > 0),
    label: player.bind("length").transform(formatPlayerPosition),
  })


  const Icon = Widget.Icon({
    class_name: "icon",
    hexpand: true,
    hpack: "end",
    vpack: "start",
    tooltip_text: player.identity || "",
    icon: player.bind("entry").transform(entry => {
      const name = `${entry}-symbolic`
      return Utils.lookUpIcon(name) ? name : FALLBACK_ICON
    }),
  })

  const PlayPause = Widget.Button({
    class_name: "play-pause",
    on_clicked: () => player.playPause(),
    visible: player.bind("can_play"),
    child: Widget.Icon({
      icon: player.bind("play_back_status").transform(s => {
        switch (s) {
          case "Playing": return PAUSE_ICON
          case "Paused":
          case "Stopped": return PLAY_ICON
        }
      }),
    }),
  })

  const Prev = Widget.Button({
    on_clicked: () => player.previous(),
    visible: player.bind("can_go_prev"),
    child: Widget.Icon(PREV_ICON),
  })

  const Next = Widget.Button({
    on_clicked: () => player.next(),
    visible: player.bind("can_go_next"),
    child: Widget.Icon(NEXT_ICON),
  })

  return Widget.Box(
    {
      class_name: "player",
      vexpand: false,
    },
    CoverImage,
    Widget.Box(
      {
        vertical: true,
        hexpand: true,
      },
      Widget.Box([
        Title,
        Icon,
      ]),
      Artist,
      Widget.Box({ vexpand: true }),
      PositionSlider,
      Widget.CenterBox({
        start_widget: PositionLabel,
        center_widget: Widget.Box([
          Prev,
          PlayPause,
          Next,
        ]),
        end_widget: LengthLabel,
      }),
    ),
  )
}

export const Media = () => Widget.Box({
  vertical: true,
  css: "min-height: 2px; min-width: 2px;",
  visible: players.as(p => p.length > 0),
  children: players.as(p => p.map(Player)),
})