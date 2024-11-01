import { BiGasPump } from "react-icons/bi";
import { PiEngineBold } from "react-icons/pi";
import { TbSteeringWheel } from "react-icons/tb";
import { fetchData } from "../Fetch.jsx";

const handleGarage = async (vehSpawnCoords, vehicle, setNui) => {
  setNui(false);
  try {
    await fetchData(`https://${GetParentResourceName()}/closeNui`);
    await fetchData(`https://${GetParentResourceName()}/handleGarage`, "POST", {
      vehSpawnCoords: vehSpawnCoords,
      vehicle: vehicle,
    });
  } catch (error) {}
};

const handleImpound = async (vehSpawnCoords, vehicle, setNui, price) => {
  setNui(false);
  try {
    await fetchData(`https://${GetParentResourceName()}/closeNui`);
    await fetchData(
      `https://${GetParentResourceName()}/handleImpound`,
      "POST",
      {
        vehSpawnCoords: vehSpawnCoords,
        vehicle: vehicle,
        price: price,
      }
    );
  } catch (error) {}
};

function GarageCarCard({
  type,
  locale,
  vehSpawnCoords,
  vehicle,
  setNui,
  price,
}) {
  return (
    <div className="w-4/5 flex h-[85px] bg-gray-900 text-white rounded items-center">
      {" "}
      {/* Added items-center */}
      <div className="border-2 ml-1 bg-emerald-400/10 border-emerald-400/60 rounded">
        <img
          src={`./images/${vehicle.model.toLowerCase()}.png`}
          className="w-[100px] h-auto"
        />
      </div>
      <div className="flex flex-col gap-y-[4px] ml-3 mt-3">
        <div>
          <p className="font-['Oxanium'] font-bold text-xl text-emerald-400">
            {vehicle.model.toUpperCase()}
          </p>
        </div>
        <div className="flex gap-4 items-center">
          <div className="flex items-center gap-2">
            <div className="text-xl">
              <BiGasPump />
            </div>
            <div>{vehicle.fuelPrecentage}%</div>
          </div>
          <div className="flex items-center gap-2">
            <div className="text-xl">
              <PiEngineBold />
            </div>
            <div>{vehicle.engineHealthPercentage}%</div>
          </div>
        </div>
      </div>
      <div className="flex justify-center items-center ml-auto mr-5 relative">
        <img src="./plate.png" className="h-[60px] w-auto" />
        <p className="font-['Oxanium'] absolute mt-2 inset-0 flex items-center justify-center font-bold text-[22px] text-black/80 z-10">
          {vehicle.plate}
        </p>
      </div>
      <div className="flex justify-center items-center ml-auto mr-5">
        {type === "garage" ? (
          <button
            onClick={() => handleGarage(vehSpawnCoords, vehicle, setNui)}
            type="button"
            className="shadow-lg shadow-emerald-400/50 px-3 py-2 text-base font-medium text-center inline-flex items-center text-white bg-emerald-400 rounded-lg hover:bg-emerald-500 focus:ring-4 ease-out duration-300 focus:outline-none"
          >
            <TbSteeringWheel className="w-6 h-6 mr-2 text-white" />
            <p className="font-['Oxanium'] font-bold">{locale.take_out}</p>
          </button>
        ) : (
          <button
            onClick={() =>
              handleImpound(vehSpawnCoords, vehicle, setNui, price)
            }
            type="button"
            className="shadow-lg shadow-emerald-400/50 px-3 py-2 text-base font-medium text-center inline-flex items-center text-white bg-emerald-400 rounded-lg hover:bg-emerald-500 focus:ring-4 ease-out duration-300 focus:outline-none"
          >
            <TbSteeringWheel className="w-6 h-6 mr-2 text-white" />
            <p className="font-['Oxanium'] font-bold">{locale.pay_impound}</p>
          </button>
        )}
      </div>
    </div>
  );
}

export default GarageCarCard;
