# Allow the system to run appimages natively
{
    programs.appimage = {
         enable = true;
         binfmt = true;
    };
}