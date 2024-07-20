import { Application } from "types/service/applications"

const { query } = await Service.import("applications")

const WINDOW_NAME = "applauncher"

const AppItem = (app: Application) => Widget.Button({
  on_clicked: () => {
    App.closeWindow(WINDOW_NAME)
    app.launch()
  },
  attribute: { app },
  class_name: "app",
  child: Widget.Box({
    children: [
      Widget.Icon({
        icon: app.icon_name || "",
        size: 42,
      }),
      Widget.Label({
        class_name: "app-title",
        label: app.name,
        xalign: 0,
        vpack: "center",
        truncate: "end",
      }),
    ],
  }),
})

const Apps = ({ width = 500, height = 500, spacing = 12 }) => {
  // list of application buttons
  let applications = query("").map(AppItem)

  // container holding the buttons
  const list = Widget.Box({
    vertical: true,
    children: applications,
    spacing,
  })

  // repopulate the box, so the most frequent apps are on top of the list
  function repopulate() {
    applications = query("").map(AppItem)
    list.children = applications
  }

  // search entry
  const entry = Widget.Entry({
    hexpand: true,
    css: `margin-bottom: ${spacing}px;`,

    // to launch the first item on Enter
    on_accept: () => {
      // make sure we only consider visible (searched for) applications
      const results = applications.filter((item) => item.visible);
      if (results[0]) {
        App.toggleWindow(WINDOW_NAME)
        results[0].attribute.app.launch()
      }
    },

    // filter out the list
    on_change: ({ text }) => applications.forEach(item => {
      item.visible = item.attribute.app.match(text ?? "")
    }),
  })

  return Widget.Box({
    vertical: true,
    class_name: "applauncher",
    css: `margin: ${spacing * 2}px;`,
    children: [
      entry,

      // wrap the list in a scrollable
      Widget.Scrollable({
        hscroll: "never",
        css: `min-width: ${width}px;`
          + `min-height: ${height}px;`,
        child: list,
      }),
    ],
    setup: self => self.hook(App, (_, windowName, visible) => {
      if (windowName !== WINDOW_NAME)
        return

      // when the applauncher shows up
      if (visible) {
        repopulate()
        entry.text = ""
        entry.grab_focus()
      }
    }),
  })
}

// there needs to be only one instance
export const AppLauncher = () => Widget.Window({
  name: WINDOW_NAME,
  setup: self => self.keybind("Escape", () => {
    App.closeWindow(WINDOW_NAME)
  }),
  visible: false,
  class_name: "applauncher-window",
  keymode: "exclusive",
  child: Apps({
    width: 500,
    height: 500,
    spacing: 12,
  }),
})
