# Godot MCP для Underworld

Проект настроен на GoPeak `2.3.8` — MCP-сервер для Godot 4.

## Проверено

```bash
npx -y gopeak@2.3.8 --help
```

Godot найден здесь:

```bash
/usr/bin/godot
```

## Как подключить

MCP-конфиг уже лежит в корне проекта:

```text
.mcp.json
```

Если клиент поддерживает проектный MCP-конфиг, открой папку `/home/tux/Underworld` и перезапусти клиент/чат.

Если клиент просит вставить конфиг вручную, используй:

```json
{
  "mcpServers": {
    "godot": {
      "command": "npx",
      "args": ["-y", "gopeak@2.3.8"],
      "env": {
        "GODOT_PATH": "/usr/bin/godot",
        "GOPEAK_TOOL_PROFILE": "compact",
        "GODOT_PROJECT_PATH": "/home/tux/Underworld"
      }
    }
  }
}
```

## Что это даст

- запуск Godot-проекта через MCP;
- чтение debug output;
- проверка ошибок;
- инспекция сцен и нод;
- более быстрый цикл “запустить → увидеть проблему → исправить”.

После подключения MCP можно просить: “запусти сцену, сделай скрин, проверь ошибки и поправь”.
