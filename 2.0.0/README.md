# Home
<center>
<p>Non-volatile surfaces for GameMaker.<br>

[Download the latest .yymp here!](https://github.com/tabularelf/Canvas/releases)

</center>

---

Canvas is a non-volatile surface solution for GameMaker, by keeping buffer copies of surfaces and automatically refreshing surfaces on demand.

# Features
- Copy of surface contents between each `.Finish()` and `.UpdateCache()` call.
- Built-in low performance garbage collector for each Canvas instance.
- Control over when and where the buffer caching happens.
- Saving and loading buffer versions of surfaces.
- Fetch pixel data from the buffer cache (including the new surface formats).
- Per Canvas instance surface depth toggable (or globally affected via `surface_get_disabled_depth()` upon new Canvas instance).
- Interface with `application_surface` as a Canvas instance.
- Smart resizing of Canvases.

# Supported Platforms

|  Windows  |  MacOSX  |  Linux  |  iOS  |  Android  |  HTML5  |  Opera GX  |  Console  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |


# License

Canvas is under the [MIT License](https://github.com/tabularelf/Canvas/blob/main/LICENSE).