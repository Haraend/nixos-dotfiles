# Disk usage analysis - ncdu (TUI) + Baobab (GUI)
# Wired into Thunar as right-click custom actions on folders.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ncdu # TUI disk usage analyzer (also handy over SSH)
    baobab # GNOME disk usage analyzer (rings view)
  ];

  # Thunar custom actions. force = true takes over the stock Thunar-generated
  # uca.xml; its original "Open Terminal Here" entry is preserved below.
  xdg.configFile."Thunar/uca.xml" = {
    force = true;
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
        <action>
          <icon>utilities-terminal</icon>
          <name>Open Terminal Here</name>
          <submenu></submenu>
          <unique-id>1769160713864472-1</unique-id>
          <command>xdg-terminal-exec</command>
          <description>Example for a custom action</description>
          <range></range>
          <patterns>*</patterns>
          <startup-notify/>
          <directories/>
        </action>
        <action>
          <icon>baobab</icon>
          <name>Analyze Disk Usage (Baobab)</name>
          <submenu></submenu>
          <unique-id>1755900000000000-2</unique-id>
          <command>baobab %f</command>
          <description>Show what is using space inside the selected folder</description>
          <range></range>
          <patterns>*</patterns>
          <directories/>
        </action>
        <action>
          <icon>drive-multidisk</icon>
          <name>Analyze Disk Usage (ncdu)</name>
          <submenu></submenu>
          <unique-id>1755900000000000-3</unique-id>
          <command>xdg-terminal-exec ncdu %f</command>
          <description>Interactive terminal folder size explorer</description>
          <range></range>
          <patterns>*</patterns>
          <directories/>
        </action>
      </actions>
    '';
  };
}
