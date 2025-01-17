module Registry.Api.Handler.DocumentTemplate.Api where

import Servant

import Registry.Api.Handler.DocumentTemplate.Detail_Bundle_GET
import Registry.Api.Handler.DocumentTemplate.Detail_GET
import Registry.Api.Handler.DocumentTemplate.List_Bundle_POST
import Registry.Api.Handler.DocumentTemplate.List_GET
import Registry.Model.Context.BaseContext

type DocumentTemplateAPI =
  List_GET
    :<|> Templates__List_GET
    :<|> List_Bundle_POST
    :<|> Detail_GET
    :<|> Templates__Detail_Bundle_GET
    :<|> Detail_Bundle_GET

documentTemplateApi :: Proxy DocumentTemplateAPI
documentTemplateApi = Proxy

documentTemplateServer :: ServerT DocumentTemplateAPI BaseContextM
documentTemplateServer = list_GET :<|> list_GET :<|> list_bundle_POST :<|> detail_GET :<|> detail_bundle_GET :<|> detail_bundle_GET
