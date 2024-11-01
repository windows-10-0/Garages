import { BiExit } from "react-icons/bi";
import GarageCarCard from "./components/GarageCarCard.jsx";
import { useState, useEffect } from "react";
import { fetchData } from "./Fetch.jsx";
import { LiaFrownSolid } from "react-icons/lia";
import "./scrollbar.css";

function App() {
  const [nui, setNui] = useState(false);
  const [locale, setLocale] = useState({});
  const [ownedVehicles, setOwnedVehicles] = useState([]);
  const [type, setType] = useState("");
  const [vehSpawnCoords, setVehSpawnCoords] = useState("");
  const [price, setPrice] = useState("");

  const fetchOwnedVehicles = async (type) => {
    if (!type) return;

    try {
      const getOwnedVehiclesData = await fetchData(
        `https://${GetParentResourceName()}/getOwnedVehicles`,
        "POST",
        { type: type }
      );
      setOwnedVehicles(getOwnedVehiclesData);
    } catch (error) {}
  };

  const closeNui = async () => {
    setNui(false);
    setOwnedVehicles([]);
    try {
      await fetchData(`https://${GetParentResourceName()}/closeNui`);
    } catch (error) {}
  };

  useEffect(() => {
    const handleMessage = (event) => {
      const data = event.data;
      switch (data.action) {
        case "open":
          {
            data.price && setPrice(data.price);
          }
          setType(data.type);
          fetchOwnedVehicles(data.type);
          setVehSpawnCoords(data.vehSpawnCoords);
          setNui(true);
          break;
        case "close":
          setNui(false);
          break;
        default:
          break;
      }
    };

    const fetchLocale = async () => {
      try {
        const localeData = await fetchData(
          `https://${GetParentResourceName()}/setLocale`,
          "POST",
          { status: false }
        );
        setLocale(localeData);
      } catch (error) {}
    };

    fetchLocale();
    window.addEventListener("message", handleMessage);
    return () => {
      window.removeEventListener("message", handleMessage);
    };
  }, []);

  return (
    <>
      {nui && (
        <div className="select-none absolute flex flex-row items-start justify-center left-[50%] top-[50%] translate-x-[-50%] translate-y-[-50%] w-[900px] h-[600px] bg-gray-800 rounded-lg animate-fadeIn">
          <div>
            <button
              onClick={closeNui}
              className="fixed top-3 right-3 w-[30px] h-[30px] flex items-center justify-center rounded bg-red-400 hover:bg-red-500 hover:shadow-lg hover:shadow-red-500/50 ease duration-300 transform hover:scale-110"
            >
              <BiExit className="text-white text-2xl" />
            </button>
            <div className="fixed top-3 left-[50%] translate-x-[-50%] font-bold text-3xl text-white font-['Oxanium']">
              {(type === "garage" && locale.garages_title) ||
                locale.impound_title}
            </div>
          </div>
          <div
            className="flex flex-col h-full gap-3 justify-start items-center mt-[80px] w-full overflow-y-auto"
            style={{ maxHeight: "calc(95% - 80px)" }}
          >
            {ownedVehicles.length > 0 ? (
              <div className="flex flex-col gap-3 w-full items-center">
                {ownedVehicles.map((vehicle) => (
                  <GarageCarCard
                    key={vehicle.plate}
                    type={type}
                    locale={locale}
                    vehSpawnCoords={vehSpawnCoords}
                    vehicle={vehicle}
                    setNui={setNui}
                    price={price}
                    className="transition-transform transform hover:scale-105"
                  />
                ))}
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center w-full h-full">
                <div>
                  <p className="text-emerald-400 font-bold text-2xl font-['Oxanium']">
                    {type === "garage"
                      ? locale.no_cars_garage
                      : locale.no_cars_impound}
                  </p>
                </div>
                <div className="text-emerald-400/30">
                  <LiaFrownSolid className="w-[100px] h-[100px]" />
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </>
  );
}

export default App;
