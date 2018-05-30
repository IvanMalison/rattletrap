module Rattletrap.Decode.SpawnedReplication
  ( decodeSpawnedReplicationBits
  ) where

import Data.Semigroup ((<>))
import Rattletrap.Decode.Common
import Rattletrap.Decode.Initialization
import Rattletrap.Decode.Word32le
import Rattletrap.Type.ClassAttributeMap
import Rattletrap.Type.CompressedWord
import Rattletrap.Type.SpawnedReplication
import Rattletrap.Type.Str
import Rattletrap.Type.Word32le

import qualified Control.Monad.Trans.Class as Trans
import qualified Control.Monad.Trans.State as State
import qualified Data.Map as Map

decodeSpawnedReplicationBits
  :: (Int, Int, Int)
  -> ClassAttributeMap
  -> CompressedWord
  -> State.StateT
       (Map.Map CompressedWord Word32le)
       DecodeBits
       SpawnedReplication
decodeSpawnedReplicationBits version classAttributeMap actorId = do
  flag <- Trans.lift getBool
  nameIndex <- decodeWhen
    (version >= (868, 14, 0))
    (Trans.lift decodeWord32leBits)
  name <- lookupName classAttributeMap nameIndex
  objectId <- Trans.lift decodeWord32leBits
  State.modify (Map.insert actorId objectId)
  objectName <- lookupObjectName classAttributeMap objectId
  className <- lookupClassName objectName
  let hasLocation = classHasLocation className
  let hasRotation = classHasRotation className
  initialization <- Trans.lift
    (decodeInitializationBits version hasLocation hasRotation)
  pure
    ( SpawnedReplication
      flag
      nameIndex
      name
      objectId
      objectName
      className
      initialization
    )

lookupName :: Monad m => ClassAttributeMap -> Maybe Word32le -> m (Maybe Str)
lookupName classAttributeMap maybeNameIndex = case maybeNameIndex of
  Nothing -> pure Nothing
  Just nameIndex ->
    case getName (classAttributeMapNameMap classAttributeMap) nameIndex of
      Nothing -> fail ("could not get name for index " <> show nameIndex)
      Just name -> pure (Just name)

lookupObjectName :: Monad m => ClassAttributeMap -> Word32le -> m Str
lookupObjectName classAttributeMap objectId =
  case getObjectName (classAttributeMapObjectMap classAttributeMap) objectId of
    Nothing -> fail ("could not get object name for id " <> show objectId)
    Just objectName -> pure objectName

lookupClassName :: Monad m => Str -> m Str
lookupClassName objectName = case getClassName objectName of
  Nothing -> fail ("could not get class name for object " <> show objectName)
  Just className -> pure className
