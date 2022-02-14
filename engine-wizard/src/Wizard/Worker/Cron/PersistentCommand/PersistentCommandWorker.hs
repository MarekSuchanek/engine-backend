module Wizard.Worker.Cron.PersistentCommand.PersistentCommandWorker
  ( persistentCommandWorker
  ) where

import Control.Lens ((^.))
import Control.Monad (when)
import Control.Monad.Reader (liftIO)
import Data.Foldable (traverse_)
import qualified Data.Text as T
import Prelude hiding (log)
import System.Cron hiding (cron)

import LensesConfig
import Wizard.Database.DAO.App.AppDAO
import Wizard.Model.Context.BaseContext
import Wizard.Service.PersistentCommand.PersistentCommandService
import Wizard.Util.Context
import Wizard.Util.Logger

persistentCommandWorker :: (MonadSchedule m, Applicative m) => BaseContext -> m ()
persistentCommandWorker context =
  when
    (context ^. serverConfig . persistentCommand . retryJob . enabled)
    (addJob (job context) (T.pack $ context ^. serverConfig . persistentCommand . retryJob . cron))

-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
job :: BaseContext -> IO ()
job context =
  let loggingLevel = context ^. serverConfig . logging . level
   in runLogging loggingLevel $ do
        log "starting"
        (Right apps) <- liftIO $ runAppContextWithBaseContext findApps context
        let appUuids = fmap (^. uuid) apps
        liftIO $ traverse_ (runAppContextWithBaseContext' runPersistentCommands context) appUuids
        log "ended"

log msg = logInfo _CMP_WORKER ("PersistentCommandWorker: " ++ msg)