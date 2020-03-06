module Wizard.Api.Resource.Template.TemplateDTO where

import qualified Data.UUID as U
import GHC.Generics

data TemplateDTO =
  TemplateDTO
    { _templateDTOUuid :: U.UUID
    , _templateDTOName :: String
    , _templateDTOAllowedKMs :: [TemplateAllowedKMDTO]
    , _templateDTOFormats :: [TemplateFormatDTO]
    }
  deriving (Show, Eq, Generic)

data TemplateAllowedKMDTO =
  TemplateAllowedKMDTO
    { _templateAllowedKMDTOOrgId :: Maybe String
    , _templateAllowedKMDTOKmId :: Maybe String
    , _templateAllowedKMDTOMinVersion :: Maybe String
    , _templateAllowedKMDTOMaxVersion :: Maybe String
    }
  deriving (Show, Eq, Generic)

data TemplateFormatDTO =
  TemplateFormatDTO
    { _templateFormatDTOUuid :: U.UUID
    , _templateFormatDTOName :: String
    , _templateFormatDTOIcon :: String
    }
  deriving (Show, Eq, Generic)
