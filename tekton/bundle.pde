class BundleEditor {
  Group grp;
  Textlabel tlTitle;
  Button[][] btnBundles = new Button[4][16];
  Button[] btnLess = new Button[4];
  Button[] btnMore = new Button[4];
  Button btnReload, btnWrite, btnSave, btnLoad;
  Textfield tfPath;
  Button btnSelected;
  Button[] btnPresets = new Button[16];
  int bundle_slots[] = new int[4];
  int bundles[][] = new int[4][16];
  int selected_b, selected_s = -1;

  BundleEditor(int x, int y) {
    grp = cp5.addGroup("bundleEditor")
      .setPosition(x, y)
      .hideBar()
      .hideArrow();

    tlTitle = cp5.addTextlabel("bundleTitle")
      .setText("Bundles")
      .setPosition(320, 20)
      .setColorValue(0xff8888ff)
      .setFont(createFont("Arial", 32))
      .setGroup(grp);

    btnSelected = cp5.addButton("bundleSelected")
      .setPosition(0, 0)
      .setSize(40, 40)
      .setColorBackground(color(192))
      .setCaptionLabel("")
      .setGroup(grp)
      .hide();

    btnReload = cp5.addButton("bundleReload")
      .setPosition(110, 250)
      .setSize(80, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("Reload Bundles")
      .setGroup(grp);

    btnWrite = cp5.addButton("bundleWrite")
      .setPosition(210, 250)
      .setSize(80, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("Write Bundles")
      .setGroup(grp);

    btnSave = cp5.addButton("bundleSave")
      .setPosition(640, 250)
      .setSize(30, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("Save")
      .setGroup(grp);

    btnLoad = cp5.addButton("bundleLoad")
      .setPosition(680, 250)
      .setSize(30, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("Load")
      .setGroup(grp);

    tfPath = cp5.addTextfield("bundlePath")
      .setValue("")
      .setPosition(490, 250)
      .setSize(140, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("")
      .setText("primer.bundle")
      .setGroup(grp);

    for (int b = 0; b < 4; b++) {
      btnLess[b] = cp5.addButton("bundleLess" + (b + 1))
        .setPosition(20, 78 + (b * 40))
        .setValue(b)
        .setSize(40, 20)
        .setColorBackground(color(64))
        .setCaptionLabel("Less")
        .setGroup(grp);

      btnMore[b] = cp5.addButton("bundleMore" + (b + 1))
        .setPosition(740, 78 + (b * 40))
        .setValue(b)
        .setSize(40, 20)
        .setColorBackground(color(64))
        .setCaptionLabel("More")
        .setGroup(grp);

      for (int s = 0; s < 16; s++) {
        int v = (b * 16) + s;
        btnBundles[b][s] = cp5.addButton("bundleSlot" + v, v)
          .setPosition(84 + (s * 40), 70 + (b * 40))
          .setSize(32, 32)
          .setCaptionLabel("")
          .setGroup(grp)
          .setColorBackground(color(64));
      }
    }

    for (int s = 0; s < 16; s++) {
      btnPresets[s] = cp5.addButton("bundlePreset" + s, s)
        .setPosition(84 + (s * 40), 400)
        .setSize(32, 32)
        .setCaptionLabel("PS" + (s + 1))
        .setGroup(grp)
        .setColorBackground(color(64));
    }
  }

  void hide() {
    grp.hide();
  }

  void show() {
    grp.show();
  }

  void select(int i) {
    int b = i / 16;
    int s = i % 16;
    if (s < bundle_slots[b]) {
      float[] pos = btnBundles[b][s].getPosition();
      btnSelected.setPosition(pos[0] - 4, pos[1] - 4);
      btnSelected.show();
    }
    selected_b = b;
    selected_s = s;
  }

  void deselect() {
    selected_b = selected_s = -1;
    btnSelected.hide();
  }

  void guiChangeSlot(int val) {
    if (selected_s >= 0) {
      setv((20 * selected_b) + selected_s + 1, val);
    }
  }

  int update(int addr, int val) {
    if (addr % 20 == 0) {
      return setNumSlots(addr / 20, val);
    } else {
      return setSlot(addr / 20, (addr % 20) - 1, val);
    }
  }

  int setSlot(int b, int s, int v) {
    bundles[b][s] = v;
    if (s < bundle_slots[b]) {
      btnBundles[b][s].setCaptionLabel("PS" + (v + 1)).setColorBackground(color(64));
    } else {
      btnBundles[b][s].setCaptionLabel("off").setColorBackground(0);
    }
    return v;
  }

  int setNumSlots(int b, int val) {
    if (val == 100) {
      val = bundle_slots[b] + 1;
    } else if (val == 99) {
      val = bundle_slots[b] - 1;
      if (selected_b == b && selected_s >= val) {
        selected_s = -1;
        btnSelected.hide();
      }
    }

    if (val < 1 || val > 16) {
      return bundle_slots[b];
    }
    bundle_slots[b] = val;
    if (val == 1) {
      btnLess[b].hide();
      btnMore[b].show();
    } else if (val == 16) {
      btnLess[b].show();
      btnMore[b].hide();
    } else {
      btnLess[b].show();
      btnMore[b].show();
    }
    for (int i = 0; i < 16; i++) {
      if (i < val) {
        btnBundles[b][i].setCaptionLabel("PS" + (bundles[b][i] + 1)).setColorBackground(color(64));
      } else {
        btnBundles[b][i].setCaptionLabel("off").setColorBackground(0);
      }
    }
    return bundle_slots[b];
  }

  void setv(int addr, int val) {
    val = update(addr, val);
    sendCmd('W', 16, addr, val);
  }

  void save() {
    saveJSONArray(asJson(), tfPath.getText());
  }

  void load() {
    fromJson(loadJSONArray(tfPath.getText()));
  }

  JSONArray asJson() {
    JSONArray bundles = new JSONArray();
    for (int i = 0; i < 4; i++) {
      bundles.setJSONObject(i, bundleAsJson(i));
    }
    return bundles;
  }

  JSONObject bundleAsJson(int i) {
    JSONObject json = new JSONObject();
    json.setInt("active", bundle_slots[i]);
    JSONArray slots = new JSONArray();
    for (int j = 0; j < 16; j++) {
      slots.setInt(j, bundles[i][j]);
    }
    json.setJSONArray("slots", slots);
    return json;
  }

  void bundleFromJson(JSONObject json, int i) {
    setv(i * 20, json.getInt("active"));
    JSONArray slots = json.getJSONArray("slots");
    for (int j = 0; j < max(slots.size(), 16); j++) {
      setv((i * 20) + j + 1, slots.getInt(j));
    }
  }

  void fromJson(JSONArray bundles) {
    for (int i = 0; i < max(bundles.size(), 4); i++) {
      bundleFromJson(bundles.getJSONObject(i), i);
    }
  }

  void refresh() {
    btnSelected.hide();
    for (int b = 0; b < 4; b++) {
      if (bundle_slots[b] == 1) {
        btnLess[b].hide();
        btnMore[b].show();
      } else if (bundle_slots[b] == 16) {
        btnLess[b].show();
        btnMore[b].hide();
      } else {
        btnLess[b].show();
        btnMore[b].show();
      }
      for (int s = 0; s < 16; s++) {
        if (s < bundle_slots[b]) {
          btnBundles[b][s].setCaptionLabel("PS" + (bundles[b][s] + 1)).setColorBackground(color(64));
        } else {
          btnBundles[b][s].setCaptionLabel("off").setColorBackground(0);
        }
      }
    }
  }
}
