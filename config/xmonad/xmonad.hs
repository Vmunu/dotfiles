--          ____
--   _   _ / ___|  UmbralGoat [Vox]
--  | | | | |  _   https://www.github.com/VoxT1
--  | |_| | |_| |  https://www.twitter.com/umbralgoat
--   \__,_|\____|  dr4goat

-- Note: For XMonad to compile for me, it seems that libffi must be downgraded to version 3.3-r2 on Gentoo Linux.

{- Base -}
import XMonad
import System.Directory
import System.IO (hClose, hPutStr, hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

{- Actions -}
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

{- Data -}
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

{- Hooks -}
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.WorkspaceHistory

{- Layouts -}
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Magnifier

{- Layouts modifiers -}
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

{- Utilities -}
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP, mkNamedKeymap)
import XMonad.Util.NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

{- Color Scheme Choices -}
-- DoomOne
-- Dracula
-- GruvboxDark
-- MonokaiPro
-- Nord
-- OceanicNext
-- Palenight
-- SolarizedDark
-- SolarizedLight
-- TomorrowNight

import Colors.DoomOne

myFont :: String
myFont = "xft:Mononoki:regular:size=12:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask			-- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "alacritty"		-- Sets default terminal

myBrowser :: String
myBrowser = "firefox"			-- Sets default browser

myMinecraft :: String
myMinecraft = "prismlauncher"		-- Sets default Minecraft launcher

myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs' "  -- Makes emacs keybindings easier to type

myFileManager :: String
myFileManager = "thunar"		-- Sets default file manager

myEditor :: String
myEditor = myTerminal ++ " -e nvim "    -- Sets Neovim as editor

myBorderWidth :: Dimension
myBorderWidth = 2           		-- Sets border width for windows

myNormColor :: String      		-- Border color of normal windows
myNormColor   = colorBack   		-- This variable is imported from Colors.THEME

myFocusColor :: String      		-- Border color of focused windows
myFocusColor  = color15    		-- This variable is imported from Colors.THEME

mySoundPlayer :: String
mySoundPlayer = "ffplay -nodisp -autoexit " -- The program that will play system sounds

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
  spawn "killall conky"   -- Kill current conky on each restart
  spawn "killall trayer"  -- Kill current trayer on each restart

  spawnOnce "xrandr --output DP-0 --mode 3440x1440 --rate 144 &"		-- Xrandr (One screen)
  spawn "/usr/bin/emacs --daemon &" 						-- emacs daemon for the emacsclient
  spawn "/usr/libexec/polkit-gnome-authentication-agent-1 &"			-- Polkit Daemon
  spawn "/usr/lib/xfce4/notifyd/xfce4-notifyd &"				-- Polkit Daemon
  spawnOnce "picom --experimental-backend &"					-- Compositor
  spawnOnce "nitrogen --restore &"						-- Wallpaper
  spawnOnce "$HOME/.config/polybar/launch.sh &"					-- Bar
  spawnOnce "CM_LAUNCHER=rofi clipmenud"					-- Clipboard

  spawnOnce "dunst &"								-- Notification Daemon
  spawnOnce "nm-applet &"							-- Networking Applet
  spawnOnce "flameshot &"							-- Screenshots
  spawn "xfce4-power-manager &"							-- Power manager
  spawn "blueberry-tray &"							-- Bluetooth
  spawnOnce "xsetroot -cursor_name left_ptr &"					-- Fix Cursor
  setWMName "Xmonad"

myNavigation :: TwoD a (Maybe a)
myNavigation = makeXEventhandler $ shadowWithKeymap navKeyMap navDefaultHandler
 where navKeyMap = M.fromList [
          ((0,xK_Escape), cancel)
         ,((0,xK_Return), select)
         ,((0,xK_slash) , substringSearch myNavigation)
         ,((0,xK_Left)  , move (-1,0)  >> myNavigation)
         ,((0,xK_h)     , move (-1,0)  >> myNavigation)
         ,((0,xK_Right) , move (1,0)   >> myNavigation)
         ,((0,xK_l)     , move (1,0)   >> myNavigation)
         ,((0,xK_Down)  , move (0,1)   >> myNavigation)
         ,((0,xK_j)     , move (0,1)   >> myNavigation)
         ,((0,xK_Up)    , move (0,-1)  >> myNavigation)
         ,((0,xK_k)     , move (0,-1)  >> myNavigation)
         ,((0,xK_y)     , move (-1,-1) >> myNavigation)
         ,((0,xK_i)     , move (1,-1)  >> myNavigation)
         ,((0,xK_n)     , move (-1,1)  >> myNavigation)
         ,((0,xK_m)     , move (1,-1)  >> myNavigation)
         ,((0,xK_space) , setPos (0,0) >> myNavigation)
         ]
       navDefaultHandler = const myNavigation

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                (0x28,0x2c,0x34) -- lowest inactive bg
                (0x28,0x2c,0x34) -- highest inactive bg
                (0xc7,0x92,0xea) -- active bg
                (0xc0,0xa7,0x9a) -- inactive fg
                (0x28,0x2c,0x34) -- active fg

-- gridSelect menu layout
mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    , gs_navigate    = myNavigation
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 180
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

runSelectedAction' :: GSConfig (X ()) -> [(String, X ())] -> X ()
runSelectedAction' conf actions = do
    selectedActionM <- gridselect conf actions
    case selectedActionM of
        Just selectedAction -> selectedAction
        Nothing -> return ()

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ limitWindows 5
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ simplestFloat
grid     = renamed [Replace "grid"]
           $ limitWindows 9
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ limitWindows 9
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 8
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ limitWindows 7
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
	   $ mySpacing 8
           $ ThreeCol 1 (3/100) (3/7)
threeRow = renamed [Replace "threeRow"]
           $ limitWindows 7
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme
tallAccordion  = renamed [Replace "tallAccordion"]
           $ Accordion
wideAccordion  = renamed [Replace "wideAccordion"]
           $ Mirror Accordion

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = color15
                 , inactiveColor       = color08
                 , activeBorderColor   = color15
                 , inactiveBorderColor = colorBack
                 , activeTextColor     = colorBack
                 , inactiveTextColor   = color16
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
  { swn_font              = "xft:Mononoki:bold:size=60"
  , swn_fade              = 1.0
  , swn_bgcolor           = "#1c1f24"
  , swn_color             = "#ffffff"
  }

-- The layout hook
myLayoutHook = avoidStruts
               $ mouseResize
               $ windowArrange
               $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout = withBorder myBorderWidth threeCol
                                        ||| tall
                                        ||| noBorders monocle
                                        ||| floats
                                        ||| noBorders tabs
                                        ||| grid
                                        ||| spirals
                                        ||| threeRow
                                        ||| tallAccordion
                                        ||| wideAccordion

--myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
--myWorkspaces    = ["\61612","\61899","\61947","\61635","\61502","\61501","\61705","\61564","\62150","\61872"]
myWorkspaces = ["work 1", "work 2", "work 3", "www" , "school 1", "school 2", "chat 1", "chat 2", "dev"]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
  -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
  -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
  -- I'm doing it this way because otherwise I would have to write out the full
  -- name of my workspaces and the names would be very long if using clickable workspaces.
  [ className =? "confirm"         --> doFloat
  , className =? "file_progress"   --> doFloat
  , className =? "dialog"          --> doFloat
  , className =? "download"        --> doFloat
  , className =? "error"           --> doFloat
  , className =? "notification"    --> doFloat
  , className =? "pinentry-gtk-2"  --> doFloat
  , className =? "splash"          --> doFloat
  , className =? "toolbar"         --> doFloat
  , className =? "Yad"             --> doCenterFloat
  , className =? "RuneLite"             --> doCenterFloat
  , className =? "GParted"              --> doCenterFloat
  , className =? "MultiMC"		--> doCenterFloat
  , className =? "PrismLauncher"	--> doCenterFloat
  , className =? "Gimp"            	--> doCenterFloat
  , className =? "Pavucontrol"		--> doCenterFloat
  , className =? "Org.gnome.Nautilus"	--> doCenterFloat
  , className =? "Thunar"		--> doCenterFloat
  , className =? "Leafpad"		--> doCenterFloat
  , className =? "Mousepad"             --> doCenterFloat
  , className =? "Galculator"           --> doCenterFloat
  , className =? "virt-manager"         --> doCenterFloat
  , className =? "Deadbeef"             --> doCenterFloat
  , className =? "Eog"                  --> doCenterFloat
  , title =? "Oracle VM VirtualBox Manager"  --> doFloat
  , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
  , isFullscreen -->  doFullFloat
  ]-- <+> namedScratchpadManageHook myScratchPads

subtitle' ::  String -> ((KeyMask, KeySym), NamedAction)
subtitle' x = ((0,0), NamedAction $ map toUpper
                      $ sep ++ "\n-- " ++ x ++ " --\n" ++ sep)
  where
    sep = replicate (6 + length x) '-'

showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
showKeybindings x = addName "Show Keybindings" $ io $ do
  h <- spawnPipe $ "yad --text-info --fontname=\"SauceCodePro Nerd Font Mono 12\" --fore=#46d9ff back=#282c36 --center --geometry=1200x800 --title \"XMonad keybindings\""
  --hPutStr h (unlines $ showKm x) -- showKM adds ">>" before subtitles
  hPutStr h (unlines $ showKmSimple x) -- showKmSimple doesn't add ">>" to subtitles
  hClose h
  return ()

myKeys :: XConfig l0 -> [((KeyMask, KeySym), NamedAction)]
myKeys c =
  --(subtitle "Custom Keys":) $ mkNamedKeymap c $
  let subKeys str ks = subtitle' str : mkNamedKeymap c ks in
  subKeys "Xmonad Essentials"
  [ ("M-C-r",		addName "Recompile XMonad"	$ spawn "xmonad --recompile")
  , ("M-S-r",		addName "Restart XMonad"	$ spawn "xmonad --restart")
  , ("M-S-<Escape>",	addName "Quit XMonad"		$ io exitSuccess)
  , ("M-q",		addName "Kill focused window"	$ kill1)
  , ("M1-<Space>",	addName "Run prompt"       	$ spawn "rofi -show run")
  -- , ("M-<Escape>",	addName "Lock"			$ spawn "i3lock -c 1b2b34")
  , ("M-<Escape>",	addName "Lock"			$ spawn "betterlockscreen -l blur")
  , ("M-/",		addName "DTOS Help"		$ spawn "~/.local/bin/dtos-help")]

  ^++^ subKeys "Switch to workspace"
  [ ("M-1", addName "Switch to workspace 1"    $ (windows $ W.greedyView $ myWorkspaces !! 0))
  , ("M-2", addName "Switch to workspace 2"    $ (windows $ W.greedyView $ myWorkspaces !! 1))
  , ("M-3", addName "Switch to workspace 3"    $ (windows $ W.greedyView $ myWorkspaces !! 2))
  , ("M-4", addName "Switch to workspace 4"    $ (windows $ W.greedyView $ myWorkspaces !! 3))
  , ("M-5", addName "Switch to workspace 5"    $ (windows $ W.greedyView $ myWorkspaces !! 4))
  , ("M-6", addName "Switch to workspace 6"    $ (windows $ W.greedyView $ myWorkspaces !! 5))
  , ("M-7", addName "Switch to workspace 7"    $ (windows $ W.greedyView $ myWorkspaces !! 6))
  , ("M-8", addName "Switch to workspace 8"    $ (windows $ W.greedyView $ myWorkspaces !! 7))
  , ("M-9", addName "Switch to workspace 9"    $ (windows $ W.greedyView $ myWorkspaces !! 8))]

  ^++^ subKeys "Send window to workspace"
  [ ("M-S-1", addName "Send to workspace 1"    $ (windows $ W.shift $ myWorkspaces !! 0))
  , ("M-S-2", addName "Send to workspace 2"    $ (windows $ W.shift $ myWorkspaces !! 1))
  , ("M-S-3", addName "Send to workspace 3"    $ (windows $ W.shift $ myWorkspaces !! 2))
  , ("M-S-4", addName "Send to workspace 4"    $ (windows $ W.shift $ myWorkspaces !! 3))
  , ("M-S-5", addName "Send to workspace 5"    $ (windows $ W.shift $ myWorkspaces !! 4))
  , ("M-S-6", addName "Send to workspace 6"    $ (windows $ W.shift $ myWorkspaces !! 5))
  , ("M-S-7", addName "Send to workspace 7"    $ (windows $ W.shift $ myWorkspaces !! 6))
  , ("M-S-8", addName "Send to workspace 8"    $ (windows $ W.shift $ myWorkspaces !! 7))
  , ("M-S-9", addName "Send to workspace 9"    $ (windows $ W.shift $ myWorkspaces !! 8))]

  ^++^ subKeys "Moving WS's"
  [ ("M-S-.",	addName "Move window to next WS"        $ shiftTo Next nonNSP >> moveTo Next nonNSP)
  , ("M-S-,",	addName "Move window to prev WS"        $ shiftTo Prev nonNSP >> moveTo Prev nonNSP)
  , ("M-.",	addName "Move to next WS"               $ moveTo Next nonNSP)
  , ("M-,",	addName "Move to prev WS"               $ moveTo Prev nonNSP)]

  ^++^ subKeys "Window navigation"
  [ ("M-j",		addName "Move focus to prev window"                $ windows W.focusUp)
  , ("M-k",		addName "Move focus to next window"                $ windows W.focusDown)
  , ("M-m",		addName "Move focus to master window"              $ windows W.focusMaster)
  , ("M-S-j",		addName "Swap focused window with prev window"   $ windows W.swapUp)
  , ("M-S-k",		addName "Swap focused window with next window"   $ windows W.swapDown)
  , ("M-S-m",		addName "Swap focused window with master window" $ windows W.swapMaster)
  , ("M-<Return>",	addName "Move focused window to master"  $ promote)]

  ^++^ subKeys "Programs"
  {- Utilities -}
  [("M1-<Return>",	addName "Launch terminal"	$ spawn (myTerminal))
  , ("M1-h",		addName "Launch File Manager"	$ spawn (myFileManager))	
  , ("M1-p",		addName "Launch Pavucontrol"	$ spawn "pavucontrol")
  , ("M-M1-h",		addName "Launch htop"		$ spawn (myTerminal ++ " -e htop"))
  , ("M-v",		addName "Launch Clipmenu"	$ spawn "CM_LAUNCHER=rofi clipmenu -p 'clipboard'")

  , ("M-r l",           addName "Redshift Low"          $ spawn "redshift -PO 4000")
  , ("M-r m",           addName "Redshift Mid"          $ spawn "redshift -PO 3000")
  , ("M-r h",           addName "Redshift High"         $ spawn "redshift -PO 2000")
  , ("M-r r",           addName "Redshift Off"          $ spawn "redshift -PO 10000")

  {- Browser -}
  , ("M1-b",		addName "Launch web browser"	$ spawn (myBrowser))

  {- Chat Programs -}
  , ("M1-c d",		addName "Launch Discord"	$ spawn "discord")
  , ("M1-c f",		addName "Launch F-Chat"		$ spawn "$HOME/.local/bin/appimages/FChat.AppImage")
  , ("M1-c t",          addName "Launch Telegram"       $ spawn "telegram-desktop")
  
  {- Music -}
  , ("M1-m s",          addName "Launch Spotify"        $ spawn "spotify")
  , ("M1-m a",          addName "Launch Audacium"       $ spawn "./.local/bin/audacium")
  , ("M1-m m",          addName "Launch MuseScore"      $ spawn "mscore")

  {- Games -}
  , ("M1-g s",          addName "Launch Steam"          $ spawn "steam")
  , ("M1-g m",          addName "Launch Minecraft"        $ spawn (myMinecraft))
  , ("M1-g b",		addName "Launch Badlion"	$ spawn "/opt/BadlionClient/BadlionClient")
  , ("M1-g r",          addName "Launch RuneLite"       $ spawn "./.local/bin/appimages/RuneLite.AppImage")

  {- Coding -}
  , ("M1-n",            addName "Launch Neovim"         $ spawn (myTerminal ++ " -e nvim"))
  , ("M1-c v",          addName "Launch VSCode"         $ spawn "vscode")
  , ("M1-c s",          addName "Launch Spyder"         $ spawn "spyder")

  {- Writing -}
  , ("M1-w e",		addName "Launch Emacs"		$ spawn "emacs")
  , ("M1-w o",          addName "Launch Writer"         $ spawn "lowriter")
  , ("M1-w v",		addName "Launch neovim"	$ spawn (myTerminal ++ " -e nvim"))
  , ("M1-w l",		addName "Launch Leafpad"	$ spawn "leafpad")

  {- Virtualization -}
  , ("M1-v v",          addName "Launch virt-manager"   $ spawn "virt-manager")]

  ^++^ subKeys "Switch layouts"
  [ ("M-<Tab>",		addName "Switch to next layout"   $ sendMessage NextLayout)
  , ("M-<Space>",	addName "Toggle noborders/full" $ sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)]

  ^++^ subKeys "Window resizing"
  [ ("M-h",	addName "Shrink window"               $ sendMessage Shrink)
  , ("M-l",	addName "Expand window"               $ sendMessage Expand)
  , ("M-M1-j",	addName "Shrink window vertically" $ sendMessage MirrorShrink)
  , ("M-M1-k",	addName "Expand window vertically" $ sendMessage MirrorExpand)]

  ^++^ subKeys "Floating windows"
  [ ("M-f",	addName "Toggle float layout"        $ sendMessage (T.Toggle "floats"))
  , ("M-t",	addName "Sink a floating window"     $ withFocused $ windows . W.sink)
  , ("M-S-t",	addName "Sink all floated windows" $ sinkAll)]

  ^++^ subKeys "Window spacing (gaps)"
  [ ("C-M1-j", addName "Decrease window spacing" $ decWindowSpacing 4)
  , ("C-M1-k", addName "Increase window spacing" $ incWindowSpacing 4)
  , ("C-M1-h", addName "Decrease screen spacing" $ decScreenSpacing 4)
  , ("C-M1-l", addName "Increase screen spacing" $ incScreenSpacing 4)]

  ^++^ subKeys "Increase/decrease windows in master pane or the stack"
  [ ("M-S-<Up>", addName "Increase clients in master pane"   $ sendMessage (IncMasterN 1))
  , ("M-S-<Down>", addName "Decrease clients in master pane" $ sendMessage (IncMasterN (-1)))
  , ("M-=", addName "Increase max # of windows for layout"   $ increaseLimit)
  , ("M--", addName "Decrease max # of windows for layout"   $ decreaseLimit)]

  ^++^ subKeys "Multimedia keys"
  [ ("<XF86AudioPlay>", addName "mocp play"           $ spawn "mocp --play")
  , ("<XF86AudioPrev>", addName "mocp next"           $ spawn "mocp --previous")
  , ("<XF86AudioNext>", addName "mocp prev"           $ spawn "mocp --next")
  , ("<XF86AudioMute>", addName "Toggle audio mute"   $ spawn "amixer set Master toggle")
  , ("<XF86AudioLowerVolume>", addName "Lower vol"    $ spawn "amixer set Master 5%- unmute")
  , ("<XF86AudioRaiseVolume>", addName "Raise vol"    $ spawn "amixer set Master 5%+ unmute")
  , ("<XF86HomePage>", addName "Open home page"       $ spawn (myBrowser ++ " https://www.youtube.com/c/DistroTube"))
  , ("<XF86Search>", addName "Web search (dmscripts)" $ spawn "dm-websearch")
  , ("<XF86Mail>", addName "Email client"             $ runOrRaise "thunderbird" (resource =? "thunderbird"))
  , ("<XF86Calculator>", addName "Calculator"         $ runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk"))
  , ("<XF86Eject>", addName "Eject /dev/cdrom"        $ spawn "eject /dev/cdrom")
  , ("<Print>", addName "Take screenshot (dmscripts)" $ spawn "flameshot gui")
  ]
  -- The following lines are needed for named scratchpads.
    where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
          nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

main :: IO ()
main = do
  -- Launching three instances of xmobar on their monitors.
  --xmproc0 <- spawnPipe ("xmobar -x 0 $HOME/.config/xmobar/" ++ colorScheme ++ "-xmobarrc")
  --xmproc1 <- spawnPipe ("xmobar -x 1 $HOME/.config/xmobar/" ++ colorScheme ++ "-xmobarrc")
  -- the xmonad, ya know...what the WM is named after!
  xmonad $ addDescrKeys' ((mod4Mask, xK_F1), showKeybindings) myKeys $ ewmh $ docks $ def
    { manageHook         = myManageHook <+> manageDocks
    , handleEventHook    = swallowEventHook (className =? "Alacritty"  <||> className =? "st-256color" <||> className =? "XTerm") (return True)
    , modMask            = myModMask
    , terminal           = myTerminal
    , startupHook        = myStartupHook
    , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
    , workspaces         = myWorkspaces
    , borderWidth        = myBorderWidth
    , normalBorderColor  = myNormColor
    , focusedBorderColor = myFocusColor
    , logHook = dynamicLogWithPP $  filterOutWsPP [scratchpadWorkspaceTag] $ xmobarPP
    }
