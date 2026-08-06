import paho.mqtt.client as mqtt
import random, time
import json
import os

MQTT_BROKER = os.getenv("MQTT_BROKER", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", 1883))
TOPIC_JOYSTICK = 'sensor/controller/joystick'  # 1 topic voor alles
TOPIC_BUTTONS = 'sensor/controller/buttons'

mqttc = mqtt.Client()
mqttc.connect(MQTT_BROKER, MQTT_PORT)

while True:
    # Simuleer joystick waarden
    x = random.randint(0, 255)
    y = random.randint(0, 255)
    magnitude = round((x**2 + y**2)**0.5, 3)
    pressed_count = random.randint(0, 6)

    # Bouw JSON payload
    joystick_payload = json.dumps({
        "x": x,
        "y": y,
        "magnitude": magnitude
    })

    # Publiceer joystick als één JSON op één topic
    mqttc.publish(TOPIC_JOYSTICK, joystick_payload)

    # Publiceer buttons apart
    mqttc.publish(TOPIC_BUTTONS, str(pressed_count))

    time.sleep(5)
