module Shared.Api.Resource.Template.TemplateJM where

import Data.Aeson

import Shared.Api.Resource.Template.TemplateDTO
import Shared.Api.Resource.Template.TemplateFormatJM ()
import Shared.Util.JSON

instance FromJSON TemplateDTO where
  parseJSON = genericParseJSON simpleOptions

instance ToJSON TemplateDTO where
  toJSON = genericToJSON simpleOptions
