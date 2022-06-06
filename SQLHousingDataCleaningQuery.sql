select * from HousingData;

--Standardize SaleDate Format
alter table HousingData add SaleDateConverted date;
update HousingData set SaleDateConverted = convert(date, saledate);
select SaleDate, SaleDateConverted from HousingData;

--Populate PropertyAddress data: PropertyAddress is the same where ParcelID is the same
select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.propertyaddress, b.propertyaddress)
from HousingData a join HousingData b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from HousingData a join HousingData b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null; 

select parcelid, PropertyAddress from HousingData where PropertyAddress is null;

--Breaking out PropertyAddress into individual columns [Address, City, State]
select PropertyAddress from HousingData;

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as City
from HousingData; --a check

alter table HousingData add Property_Address varchar(255);
update HousingData set Property_Address = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1);

alter table HousingData add Property_City varchar(255);
update HousingData set Property_City = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress));

select Property_Address, Property_City from HousingData;

--Breaking out OwnerAddress into individual columns [Address, City, State]
select OwnerAddress from HousingData;

select PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from HousingData

alter table HousingData add Owner_Address varchar(255), Owner_City varchar(255), Owner_State varchar(255);

update HousingData set Owner_Address = PARSENAME(replace(OwnerAddress, ',', '.'), 3);
update HousingData set Owner_City = PARSENAME(replace(OwnerAddress, ',', '.'), 2);
update HousingData set Owner_State = PARSENAME(replace(OwnerAddress, ',', '.'), 1);
 
select Owner_Address, Owner_City, Owner_State from HousingData;

--Change Y and N to Yes and No in "SoldAsVacant" field
select distinct SoldAsVacant, count(SoldAsVacant) from HousingData group by SoldAsVacant order by count(SoldAsVacant);

alter table HousingData add Sold_As_Vacant varchar(255);
update HousingData set Sold_As_Vacant = Case when SoldAsVacant = 'Y' then 'Yes' 
when SoldAsVacant = 'N' then 'No' else SoldAsVacant end from HousingData;

select distinct Sold_As_Vacant, count(Sold_As_Vacant) from HousingData group by Sold_As_Vacant order by count(Sold_As_Vacant);

--Removing Duplicates
with RowNumCTE as (
select *,row_number() over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
order by [UniqueID ]) as row_num from HousingData
)
delete from RowNumCTE where row_num > 1; --deletes all the duplicates

select * from HousingData;

--Delete Unused Columns
alter table HousingData drop column PropertyAddress, TaxDistrict, OwnerAddress,
SaleDate, SoldAsVacant;

select * from HousingData;