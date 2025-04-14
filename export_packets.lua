-- Setup the output path for the csv file
local home = os.getenv("HOME") or os.getenv("USERPROFILE") or "."
local file_path = home .. "/Documents/packets.csv"
local file, err = io.open(file_path, "w")

-- Ensure that the file is open
if not file then
    print("Error opening file for writing: " .. err)
    return
end

local count = 0
local file_closed = false
local capture_done = false
local packet_buffer = {}
local last_packet_time = os.time()  -- Time of the last received packet
local inactivity_timeout = 10  -- Timeout (seconds) to wait for capture to finish

-- Write the CSV headers
file:write("No.,Time,Source,Destination,Protocol,Length\n")

-- CSV escape helper function
local function escapeCSV(s)
    s = s or ""
    if s:find('[,"\n]') then
        s = '"' .. s:gsub('"', '""') .. '"'
    end
    return s
end

-- Safe string conversions
local function safe_tostring(val)
    if val == nil then return "N/A" end
    return tostring(val)
end

-- Extract the fields
local frame_number = Field.new("frame.number")
local frame_time = Field.new("frame.time_relative")
local frame_len = Field.new("frame.len")
local proto_field = Field.new("frame.protocols")
local ip_src = Field.new("ip.src")
local ip_dst = Field.new("ip.dst")
local ipv6_src = Field.new("ipv6.src")
local ipv6_dst = Field.new("ipv6.dst")
local eth_src = Field.new("eth.src")
local eth_dst = Field.new("eth.dst")

-- Function to close the current file
local function closeFile()
    if file then
        file:close()
        file = nil
        file_closed = true
    end
end

-- Function to open a new file
local function openNewFile()
    closeFile()  -- Close the existing file if any
    file, err = io.open(file_path, "w")
    if not file then
        print("Error opening file for writing: " .. err)
        return false
    end
    file:write("No.,Time,Source,Destination,Protocol,Length\n")  -- Write header
    file_closed = false
    return true
end

-- Tap declaration
local tap = Listener.new(nil, "")

-- Get the data from packets
function tap.packet(pinfo, tvb)
    if not file or file_closed then
        if not openNewFile() then
            return  -- If unable to open file, just return
        end
    end

    count = count + 1
    local num = safe_tostring(frame_number())
    local time = safe_tostring(frame_time())
    local len = safe_tostring(frame_len())
    local proto = safe_tostring(proto_field())
    local src = safe_tostring(ip_src() or ipv6_src() or eth_src())
    local dst = safe_tostring(ip_dst() or ipv6_dst() or eth_dst())

    -- Debugging: Show packet info in the console
    print("Packet " .. num .. ": " .. src .. " -> " .. dst)

    -- Store the packet data in the buffer instead of writing it directly
    table.insert(packet_buffer, table.concat({ escapeCSV(num), escapeCSV(time), escapeCSV(src), escapeCSV(dst), escapeCSV(proto), escapeCSV(len) }, ",") .. "\n")

    -- Write buffer to disk every packet
    if #packet_buffer >= 1 then
        for _, line in ipairs(packet_buffer) do
            file:write(line)
        end
        file:flush()
        packet_buffer = {}  -- Clear buffer after writing
    end

    -- Update the last packet timestamp
    last_packet_time = os.time()
end

-- Write the data to the file
function tap.draw()
    -- If capture is done, write the remaining buffered packets to the CSV
    if not capture_done and count > 0 then
        -- Check if the capture has been idle for more than the timeout
        if os.time() - last_packet_time > inactivity_timeout then
            -- Flush remaining packets in the buffer
            if #packet_buffer > 0 then
                for _, line in ipairs(packet_buffer) do
                    file:write(line)
                end
                file:flush()
                packet_buffer = {}  -- Clear buffer
            end

            print("Capture stopped due to inactivity. Closing CSV file...")

            -- Close the file properly after capturing is done
            closeFile()

            capture_done = true
            print("Capture complete. Packets exported to CSV: " .. count)
        end
    end
end

-- Ensure the capture is happening
retap_packets()  -- Make sure any pre-captured packets are processed
