module Service.Package.PackageMapper where

import Control.Lens ((^.))
import Data.Aeson
import Data.UUID (UUID)

import Api.Resources.Package.PackageDTO
import Api.Resources.Package.PackageSimpleDTO
import Api.Resources.Package.PackageWithEventsDTO
import Common.Types
import Model.Event.Event
import Model.Package.Package
import Service.Event.EventMapper

packageToDTO :: Package -> PackageDTO
packageToDTO package =
  PackageDTO
  { _pkgdtoId = package ^. pkgId
  , _pkgdtoName = package ^. pkgName
  , _pkgdtoGroupId = package ^. pkgGroupId
  , _pkgdtoArtefactId = package ^. pkgArtefactId
  , _pkgdtoVersion = package ^. pkgVersion
  , _pkgdtoDescription = package ^. pkgDescription
  , _pkgdtoParentPackage = packageToDTO <$> (package ^. pkgParentPackage)
  }

packageToSimpleDTO :: Package -> PackageSimpleDTO
packageToSimpleDTO package =
  PackageSimpleDTO
  { _pkgsdtoName = package ^. pkgName
  , _pkgsdtoGroupId = package ^. pkgGroupId
  , _pkgsdtoArtefactId = package ^. pkgArtefactId
  }

packageWithEventsToDTO :: PackageWithEvents -> PackageDTO
packageWithEventsToDTO package =
  PackageDTO
  { _pkgdtoId = package ^. pkgweId
  , _pkgdtoName = package ^. pkgweName
  , _pkgdtoGroupId = package ^. pkgweGroupId
  , _pkgdtoArtefactId = package ^. pkgweArtefactId
  , _pkgdtoVersion = package ^. pkgweVersion
  , _pkgdtoDescription = package ^. pkgweDescription
  , _pkgdtoParentPackage =
      packageWithEventsToDTO <$> (package ^. pkgweParentPackage)
  }

packageWithEventsToDTOWithEvents :: PackageWithEvents -> PackageWithEventsDTO
packageWithEventsToDTOWithEvents package =
  PackageWithEventsDTO
  { _pkgwedtoId = package ^. pkgweId
  , _pkgwedtoName = package ^. pkgweName
  , _pkgwedtoGroupId = package ^. pkgweGroupId
  , _pkgwedtoArtefactId = package ^. pkgweArtefactId
  , _pkgwedtoVersion = package ^. pkgweVersion
  , _pkgwedtoDescription = package ^. pkgweDescription
  , _pkgwedtoParentPackage =
      packageWithEventsToDTOWithEvents <$> (package ^. pkgweParentPackage)
  , _pkgwedtoEvents = toDTOs (package ^. pkgweEvents)
  }

fromDTO :: PackageDTO -> Package
fromDTO dto =
  Package
  { _pkgId = dto ^. pkgdtoId
  , _pkgName = dto ^. pkgdtoName
  , _pkgGroupId = dto ^. pkgdtoGroupId
  , _pkgArtefactId = dto ^. pkgdtoArtefactId
  , _pkgVersion = dto ^. pkgdtoVersion
  , _pkgDescription = dto ^. pkgdtoDescription
  , _pkgParentPackage = fromDTO <$> (dto ^. pkgdtoParentPackage)
  }

fromDTOWithEvents :: PackageWithEventsDTO -> PackageWithEvents
fromDTOWithEvents dto =
  PackageWithEvents
  { _pkgweId = dto ^. pkgwedtoId
  , _pkgweName = dto ^. pkgwedtoName
  , _pkgweGroupId = dto ^. pkgwedtoGroupId
  , _pkgweArtefactId = dto ^. pkgwedtoArtefactId
  , _pkgweVersion = dto ^. pkgwedtoVersion
  , _pkgweDescription = dto ^. pkgwedtoDescription
  , _pkgweParentPackage = fromDTOWithEvents <$> (dto ^. pkgwedtoParentPackage)
  , _pkgweEvents = fromDTOs (dto ^. pkgwedtoEvents)
  }

buildPackage
  :: String
  -> String
  -> String
  -> String
  -> String
  -> Maybe PackageWithEvents
  -> [Event]
  -> PackageWithEvents
buildPackage name groupId artefactId version description maybeParentPackage events =
  PackageWithEvents
  { _pkgweId = groupId ++ ":" ++ artefactId ++ ":" ++ version
  , _pkgweName = name
  , _pkgweGroupId = groupId
  , _pkgweArtefactId = artefactId
  , _pkgweVersion = version
  , _pkgweDescription = description
  , _pkgweParentPackage = maybeParentPackage
  , _pkgweEvents = events
  }
