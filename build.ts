import { type Build } from 'cmake-ts-gen';

const build: Build = {
    common: {
        project: 'minimp3',
        archs: ['x64'],
        variables: [],
        defines: ['MINIMP3_IMPLEMENTATION'],
        options: [],
        copy: {
            'minimp3/minimp3.h': 'minimp3/minimp3.c',
            'minimp3/minimp3_ex.h': 'minimp3/minimp3_ex.c',
        },
        subdirectories: [],
        libraries: {
            'minimp3': {
                sources: ['minimp3/minimp3.c', 'minimp3/minimp3_ex.c']
            }
        },
        buildDir: 'build',
        buildOutDir: 'libs',
        buildFlags: []
    },
    platforms: {
        win32: {
            windows: {},
            android: {
                archs: ['x86', 'x86_64', 'armeabi-v7a', 'arm64-v8a'],
            }
        },
        linux: {
            linux: {}
        },
        darwin: {
            macos: {}
        }
    }
}

export default build;