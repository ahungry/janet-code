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

static const JanetReg
image_cfuns[] = {
  {
    "load-image-logo-png", load_image_logo_png_wrapped, ""
  }
};
