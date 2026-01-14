{ config, lib, inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    ##########
    # CAD/3D #
    ##########
    # TODO enable when more space
    freecad # general CAD
    kicad # PCB designer
    kicad-small # PCB designer
    blender # 3D modeler, animator, and designer
    sweethome3d.application # Interior design GUI
    sweethome3d.textures-editor
    sweethome3d.furniture-editor
    candle # GRBLE/Gcode visualizer (for Cnc I think)
    mujoco # general purpose physics sim/modeler
    kdePackages.step # physics simulator
    openrocket # 3D rocket simulator/modeler
    leocad # 3D CAD modeler for legos

    # 3D printing
    bambu-studio
    #pkgs.orca-slicer # Slicer for 3D printing and Bambu printers
    #pkgs.cura
  ];
}
