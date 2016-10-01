{-# LANGUAGE DeriveGeneric #-}

module Rattletrap.AttributeValue where

import Rattletrap.Text

import qualified Data.Aeson as Aeson
import qualified Data.Binary.Bits.Get as BinaryBit
import qualified Data.Binary.Bits.Put as BinaryBit
import qualified Data.Text as Text
import qualified GHC.Generics as Generics

data AttributeValue
  = BooleanAttribute Bool
  | ByteAttribute
  | CamSettingsAttribute
  | DemolishAttribute
  | EnumAttribute
  | ExplosionAttribute
  | FlaggedIntAttribute
  | FloatAttribute
  | GameModeAttribute
  | IntAttribute
  | LoadoutAttribute
  | LoadoutOnlineAttribute
  | LoadoutsAttribute
  | LoadoutsOnlineAttribute
  | LocationAttribute
  | MusicStingerAttribute
  | PickupAttribute
  | PrivateMatchSettingsAttribute
  | QWordAttribute
  | RelativeRotationAttribute
  | ReservationAttribute
  | RigidBodyStateAttribute
  | StringAttribute
  | TeamPaintAttribute
  | UniqueIdAttribute
  | WeldedInfoAttribute
  deriving (Eq, Generics.Generic, Ord, Show)

instance Aeson.FromJSON AttributeValue

instance Aeson.ToJSON AttributeValue

getAttributeValue :: Text -> BinaryBit.BitGet AttributeValue
getAttributeValue name =
  case Text.unpack (textValue name) of
    "Engine.Actor:bBlockActors\x00" -> getBooleanAttribute
    _ -> fail ("don't know how to read attribute value " ++ show name)

getBooleanAttribute :: BinaryBit.BitGet AttributeValue
getBooleanAttribute = do
  x <- BinaryBit.getBool
  pure (BooleanAttribute x)

putAttributeValue :: AttributeValue -> BinaryBit.BitPut ()
putAttributeValue value =
  case value of
    BooleanAttribute x -> BinaryBit.putBool x
    _ -> fail "putAttributeValue"
