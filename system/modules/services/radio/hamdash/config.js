const disableSetup = false;
var topBarCenterText = `GIDEON`;

// Grid layout
var layout_cols = 4;
var layout_rows = 3;

// Menu items
// Structure is as follows HTML Color code, Option, target URL, scaling 1=Original Size, side (optional, nothing is Left, "R" is Right)
// The values are [color code, menu text, target link, scale factor, side],
// add new lines following the structure for extra menu options. The comma at the end is important!
var aURL = [
    ["2196F3", "CLUBLOG", "https://clublog.org/livestream/VA3HDL", "1.7"],
    [
        "2196F3",
        "CONTEST",
        "https://www.contestcalendar.com/fivewkcal.html",
        "1",
    ],
    ["2196F3", "DX CLUSTER", "https://dxcluster.ha8tks.hu/map/", "1"],
    [
        "2196F3",
        "LIGHTNING",
        "https://map.blitzortung.org/#3.87/36.5/-89.41",
        "1",
        "R",
    ],
    ["2196F3", "PISTAR", "http://pi-star.local/", "1.2"],
    [
        "2196F3",
        "RADAR",
        "https://weather.gc.ca/?layers=alert,radar&center=43.39961001,-78.53212031&zoom=6&alertTableFilterProv=ON",
        "1",
        "R"
    ],
    ["2196F3", "TIME.IS", "https://time.is/", "1", "R"],
    [
        "2196F3",
        "WEATHER",
        "https://openweathermap.org/weathermap?basemap=map&cities=true&layer=temperature&lat=44.0157&lon=-79.4591&zoom=5",
        "1",
        "R",
    ],
    [
        "2196F3",
        "WINDS",
        "https://earth.nullschool.net/#current/wind/surface/level/orthographic=-78.79,44.09,3000",
        "1",
        "R",
    ],
];

// Dashboard items
// Structure is Title, Image Source URL
// [Title, Image Source URL],
// the comma at the end is important!
// You can't add more items because there are only 12 placeholders on the dashboard
// but you can replace the titles and the images with anything you want.
var aIMG = [
    ["RADAR", "https://radar.weather.gov/ridge/standard/CONUS_loop.gif"],
    [
        "LOCAL RADAR",
        "https://radar.weather.gov/ridge/standard/KOKX_loop.gif",
    ],
    [
        "TROPO",
        "https://www.dxinfocentre.com/tr_map/fcst/eam006.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam009.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam012.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam015.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam018.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam021.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam024.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam027.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam030.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam033.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam036.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam039.png",
        "https://www.dxinfocentre.com/tr_map/fcst/eam042.png",
    ],
    [
        "D-RAP",
        "https://services.swpc.noaa.gov/images/animations/d-rap/global/d-rap/latest.png",
        "https://services.swpc.noaa.gov/images/animations/d-rap/global_f05/d-rap/latest.png",
        "https://services.swpc.noaa.gov/images/animations/d-rap/global_f10/d-rap/latest.png",
        "https://services.swpc.noaa.gov/images/animations/d-rap/global_f15/d-rap/latest.png",
        "https://services.swpc.noaa.gov/images/animations/d-rap/global_f20/d-rap/latest.png",
        "https://services.swpc.noaa.gov/images/animations/d-rap/global_f25/d-rap/latest.png",
        "https://services.swpc.noaa.gov/images/animations/d-rap/global_f30/d-rap/latest.png",
    ],
    [
        "SATELLITE US",
        "https://cdn.star.nesdis.noaa.gov/GOES19/ABI/CONUS/AirMass/GOES19-CONUS-AirMass-625x375.gif",
        "https://cdn.star.nesdis.noaa.gov/GOES19/GLM/CONUS/EXTENT3/GOES19-CONUS-EXTENT3-625x375.gif",
    ],
    [
        "SATELLITE NE",
        "https://cdn.star.nesdis.noaa.gov/GOES19/GLM/SECTOR/ne/EXTENT3/GOES19-NE-EXTENT3-600x600.gif",
    ],
    [
        "LIGHTNING",
        "https://images.lightningmaps.org/blitzortung/america/index.php?animation=usa",
        "https://www.blitzortung.org/en/Images/image_b_ny.png",
    ],
    [
        "SOLAR ACTIVITY",
        "https://sdo.gsfc.nasa.gov/assets/img/latest/mpeg/latest_1024_0193.mp4",
        "https://sdo.gsfc.nasa.gov/assets/img/latest/mpeg/latest_1024_0131.mp4", // 131 angstroms (can see solar flares)
        "https://services.swpc.noaa.gov/images/animations/suvi/primary/map/latest.png",
        "https://services.swpc.noaa.gov/images/animations/enlil/latest.jpg", // Solar winds
    ],
    ["Max Usable Frequency", "iframe|https://prop.kc2g.com/renders/current/mufd-normal-now.svg"],
    [
        "",
        "https://services.swpc.noaa.gov/images/animations/wam-ipe/wfs_ionosphere_new/latest.png"
    ],
    ["Geoelectric", "https://services.swpc.noaa.gov/images/animations/geoelectric/InterMagEarthScope/EmapGraphics_1m/latest.png"],
    ["PROPAGATION",
        "https://www.hamqsl.com/solar101vhf.php",
        "https://www.tvcomm.co.uk/g7izu/Autosave/ATL_HF10_AutoSave.JPG",
        "https://www.tvcomm.co.uk/g7izu/Autosave/NA_ES_AutoSave.JPG",
        "https://img.propagation.dr2w.de/n-america/10M/dr2w_animation_10M.gif",
        "https://img.propagation.dr2w.de/n-america/20M/dr2w_animation_20M.gif",
        "https://img.propagation.dr2w.de/n-america/40M/dr2w_animation_40M.gif",
    ],
];

// Image rotation intervals in milliseconds per tile - If the line below is commented, all tiles will be rotated every 30000 milliseconds (30s)
var tileDelay = [
    11200, 10000, 3000, 10100,
    10200, 10500, 10300, 10600,
    30400, 60700, 60900, 10800
];

// RSS feed items
// Structure is [feed URL, refresh interval in minutes]
var aRSS = [
    ["https://www.amsat.org/feed/", 60],           // Example RSS feed, refresh every 60 minutes
    ["https://daily.hamweekly.com/atom.xml", 120], // Example Atom feed, refresh every 120 minutes
];
