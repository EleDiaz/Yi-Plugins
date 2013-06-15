module Yi.GhcMod.GhcMod where

import Yi.Prelude
import Yi.Editor
import Yi.Buffer.Misc --(file)
import Yi.Buffer.Basic
import Yi.MiniBuffer
import Yi.Keymap
import Yi.Completion

import Prelude ()
import System.IO.Unsafe
import qualified Language.Haskell.GhcMod as GM


-- | Options by default, if modify here, you will change the behaviour throughout
defaultOptions = GM.defaultOptions

openBuffer :: String -> EditorM BufferRef
openBuffer nm = do
        stringToNewBuffer (Left "**ListFunc**") (fromString nm)

-- | A Cradle
mkCradle :: GM.Cradle
mkCradle = unsafePerformIO $ do
        (ver, _) <- GM.getGHCVersion
        GM.findCradle Nothing ver

-- | 'ModuleString' is a String
browseModule :: GM.ModuleString -> YiM String
browseModule m = io $ GM.browseModule defaultOptions m


checkSyntax :: YiM String
checkSyntax = do
        Just path <- withBuffer $ gets file
        io $ GM.checkSyntax defaultOptions mkCradle path

lintSyntax :: YiM String
lintSyntax = do
        Just path <- withBuffer $ gets file
        io $ GM.lintSyntax defaultOptions path

-- | 'Expression' is a string
infoExpr :: GM.ModuleString -> GM.Expression -> YiM String
infoExpr m expr = do
        Just path <- withBuffer $ gets file
        io $ GM.infoExpr defaultOptions mkCradle path m expr

-- | Module, line and column
typeExpr :: GM.ModuleString -> Int -> Int -> YiM String
typeExpr m l c = do
        Just path <- withBuffer $ gets file
        io $ GM.typeExpr defaultOptions mkCradle path m l c

listModules, listLanguages, listFlags :: IO String
listModules = GM.listModules defaultOptions

listLanguages = GM.listLanguages defaultOptions

listFlags = GM.listFlags defaultOptions

debugInfo :: YiM String
debugInfo = do
        Just path <- withBuffer $ gets file
        (ver, _) <- io $ GM.getGHCVersion
        io $ GM.debugInfo defaultOptions mkCradle ver path
