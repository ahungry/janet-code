// https://www.cairographics.org/tutorial/
// https://www.cairographics.org/manual/cairo-PNG-Support.html

// The main cairo site keeps timing out, the only worthwhile sample was
// under the ats lang page (hah!)

// http://ats-lang.sourceforge.net/DOCUMENT/ATS2CAIRO/HTML/c36.html

// #include "/usr/include/cairo/cairo.h"
#include <cairo.h>
#include <stdio.h>

int
main (int argc, char *argv[])
{
  cairo_surface_t *surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, 300, 300);
  cairo_t *ctx = cairo_create (surface);
  cairo_select_font_face (ctx, "Sans",
                          CAIRO_FONT_SLANT_NORMAL,
                          CAIRO_FONT_WEIGHT_BOLD);
  cairo_set_font_size (ctx, 32.0);
  cairo_set_source_rgb (ctx, 0.0, 0.0, 1.0);
  cairo_move_to (ctx, 10.0, 50.0);
  cairo_show_text (ctx, "Hello, world!");

  const char *filename = "/tmp/dummy.png";

  cairo_status_t status = cairo_surface_write_to_png (surface, filename);
  cairo_destroy (ctx);
  cairo_surface_destroy (surface);

  printf ("The status is: %d\n", status);

  return 0;
}
