module Wizard.Service.Cache.Common where

import Shared.Util.String
import Wizard.Model.Context.AppContext
import Wizard.Util.Logger

logCacheWarmBefore :: String -> AppContextM ()
logCacheWarmBefore cacheName = logDebugU _CMP_CACHE (format "Warm (before): %s" [cacheName])

logCacheWarmAfter :: String -> AppContextM ()
logCacheWarmAfter cacheName = logDebugU _CMP_CACHE (format "Warm (after): %s" [cacheName])

logCacheAddBefore :: String -> String -> AppContextM ()
logCacheAddBefore cacheName key = logDebugU _CMP_CACHE (format "Add (before): %s, key: { %s }" [cacheName, key])

logCacheAddAfter :: String -> String -> AppContextM ()
logCacheAddAfter cacheName key = logDebugU _CMP_CACHE (format "Add (after): %s, key: { %s }" [cacheName, key])

logCacheGetBefore :: String -> String -> AppContextM ()
logCacheGetBefore cacheName key = logDebugU _CMP_CACHE (format "Get (before): '%s', key: { %s }" [cacheName, key])

logCacheGetFound :: String -> String -> AppContextM ()
logCacheGetFound cacheName key = logDebugU _CMP_CACHE (format "Get (found): '%s', key: { %s }" [cacheName, key])

logCacheGetMissed :: String -> String -> AppContextM ()
logCacheGetMissed cacheName key = logDebugU _CMP_CACHE (format "Get (missed): '%s', key: { %s }" [cacheName, key])