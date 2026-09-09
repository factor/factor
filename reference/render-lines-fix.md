# Stray text lines at fractional pixel positions

The legacy OpenGL renderer allocates power-of-two texture storage and uploads
the image into its upper-left portion. A draw at a half-pixel boundary can
sample the first unused row or column. Those texels were uninitialized, producing
black lines underneath Windows Listener text. The gray rectangle around a
hovered presentation is a separate, intentional UI border.

`opengl.textures` now duplicates the final image row, column, and corner into
the adjacent padding and clamps sampling at the texture's outer edges. Image
coordinates and scaling remain unchanged. Pixel-upload state is preserved.

## Validation

- Reproduced the screenshot with a Listener at 150% backing scale and a
  `0 1/3 0 glTranslated` offset applied after `gl-draw-init-legacy` initializes
  clipping. This places text half a physical pixel below its usual position.
- The same reproduction renders without stray lines after the change.
- `factor.com -no-user-init reference/texture-edge-regression.factor` passes
  all eight GPU checks: row/column/corner padding, single-pixel dimensions,
  power-of-two and native non-power-of-two textures, and pixel-store restoration.
- Replacing `pad-texture-edges` with a no-op makes the first GPU check fail
  and the regression runner exit with status 1; the fixed runner exits 0.
- `opengl.textures`, `windows.uniscribe`, `ui.gadgets.labels`, and
  `ui.gadgets.panes` unit tests pass with zero failures.

The GPU regression requires a desktop OpenGL context and closes its own small
test window. Local screenshots and logs are under `temp/render-lines-*` and
`temp/texture-*`. Existing Listener processes retain their loaded code and cached
textures; start a new Factor process to use an updated image.
