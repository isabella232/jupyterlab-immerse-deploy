immerse_command = ' '.join([
    'yarn',
    '--cwd',
    'immerse',
    'start:fast',
    '--port={port}',
])

immerse_command = ' '.join([
    'http-server',
    'immerse/dist',
    '-p {port}'
])

c.ServerProxy.servers = {
    'immerse': {
        'command': [
            '/bin/bash', '-c',
            # Redirect all logs to a log file
            f'{immerse_command} >immerse-dev.log 2>&1'
        ],
        'launcher_entry': {
            'title': 'OmniSci Immerse'
        },
        'timeout': 30
    }
}
