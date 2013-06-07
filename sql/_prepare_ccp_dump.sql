-- These Rather Horific queries build a simplified flattended version of the 
--   ship data from the EVE DB Dump. The idea here it get the mimimum amount
--   of required information out of the db dump and into formats that can be
--   used by our django models to save us time and pain later in the more day
--   to day  database operations.

DROP VIEW almostFlatShipData;
CREATE VIEW almostFlatShipData AS
    SELECT
        invTypes.typeId,
        invTypes.groupId,
        invTypes.typeName,
        invTypes.description,
        invTypes.mass,
        invTypes.volume,
        invTypes.capacity,
        invTypes.raceId,
        invTypes.basePrice,
        invTypes.marketGroupId,
        GROUP_CONCAT(COALESCE(valueInt, valueFloat)) AS nlist
    FROM dgmTypeAttributes 
    LEFT JOIN invTypes ON (
        dgmTypeAttributes.typeId = invTypes.typeId
    )
    WHERE dgmTypeAttributes.attributeID IN (12,13,14,1137,1366)
    AND invTypes.published
    AND invTypes.groupId IN (SELECT groupId FROM invGroups WHERE categoryID = 6)
    GROUP BY dgmTypeAttributes.typeId
    ORDER BY dgmTypeAttributes.attributeID;

DROP VIEW flatShipData;
CREATE VIEW flatShipData AS
    SELECT
        typeId,
        groupId,
        typeName,
        description,
        mass,
        volume,
        capacity,
        raceId,
        basePrice,
        marketGroupId,
        SUBSTRING_INDEX(nlist,',',1) * 1 AS lowSlots,
        SUBSTRING_INDEX(SUBSTRING_INDEX(nlist,',',2),',',-1) * 1 AS midSlots,
        SUBSTRING_INDEX(SUBSTRING_INDEX(nlist,',',3),',',-1) * 1 AS hiSlots,
        SUBSTRING_INDEX(SUBSTRING_INDEX(nlist,',',4),',',-1) * 1 AS rigSlots,
        SUBSTRING_INDEX(SUBSTRING_INDEX(nlist,',',5),',',-1) * 1 AS subSystemSlots
    FROM almostFlatShipData;

