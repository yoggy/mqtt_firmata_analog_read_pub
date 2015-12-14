#!/usr/bin/ruby
#
# mqtt_firmata_analog_read_pub.rb - publish A0 voltage value using Arduino Farmata & MQTT.
#
#   $ sudo gem install arduino_firmata
#   $ sudo gem install mqtt
#   $ sudo gem install pit
#
require 'arduino_firmata'
require 'mqtt'
require 'pit'

$config = Pit.get("mqtt_firmata_analog_read_pub", :require => {
  "remote_host" => "mqtt.example.com",
  "remote_port" => 1883,
  "use_auth"    => false,
  "username"    => "username",
  "password"    => "password",
  "topic"       => "topic",
  "serial_port" => "/dev/ttyACM0",
})

$conn_opts = {
  remote_host: $config["remote_host"],
  remote_port: $config["remote_port"].to_i,
}
if $config["use_auth"] == true
  $conn_opts["username"] = $config["username"]
  $conn_opts["password"] = $config["password"]
end

$arduino =  ArduinoFirmata.connect($config['serial_port'])

def publish(c, msg)
  puts "topic=" + $config["topic"] + ", message=" + msg
  c.publish($config["topic"], msg)
end

MQTT::Client.connect($conn_opts) do |c|
   puts "connected!"

   sample_count = 100
   sleep_time = 0.1

   loop do
     total_vol = 0
     sample_count.times do 
       val = $arduino.analog_read(0)
       vol = val / 1024.0 * 5
       total_vol += vol
       sleep(sleep_time)
     end
     avg_vol = (total_vol / sample_count).round(3)
     publish(c, "vol=#{avg_vol}")
   end
end
