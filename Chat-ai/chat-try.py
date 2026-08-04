from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:4000/v1",
    api_key="sk-1234"  # No es necesario si no configuraste master_key
)

response = client.chat.completions.create(
    model="phi3:mini",
    messages=[
        {"role": "user", "content": "Hola, explícame qué es Docker"}
    ]
)

print(response.choices[0].message.content)