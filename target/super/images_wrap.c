// Generate the images.c content via:
//   iupview image.png image2.png
#include <janet.h>
#include <iup.h>

#include "images.c"

static Janet
load_image_logo_png_wrapped (int32_t argc, Janet *argv)
{
  Ihandle *image = load_image_logo_png ();

  return janet_wrap_pointer (image);
}

static Janet
string_to_pixels (int32_t argc, Janet *argv)
{
  janet_fixarity (argc, 1);

  const unsigned char *s = janet_getstring (argv, 0);
  Ihandle *res = IupImageRGBA (100, 100, s);

  return janet_wrap_pointer (res);
}

static const JanetReg
image_cfuns[] = {
  {
    "load-image-logo-png", load_image_logo_png_wrapped, ""
  },
  {
    "string-to-pixels", string_to_pixels, ""
  },
  {NULL,NULL,NULL}
};
