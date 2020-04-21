local C = {}

--client['exec']('clear')

C['Config'] = {
    ['Panel'] = 'LUA',
    ['Side'] = 'A'
}

C['JS'] = {}
C['JS']['Open'] = panorama['open']()
C['JS']['Funcs'] = panorama['loadstring']([[
    return {
        GetLastTranslation: function() {
            return cyrus_last_translation;
        }
    }
]])()

C['Libs'] = {
        ['ChatPrint'] = {
        -- credits to Aviartia for Chat Print https://github.com/Aviarita/lua-scripts/blob/master/hudchat/print_to_hudchat.lua
        ['Initialise'] = function()
            local ffi = require("ffi")
            ffi.cdef[[
                // create cdata typedef 
                typedef void***(__thiscall* FindHudElement_t)(void*, const char*);
                typedef void(__cdecl* ChatPrintf_t)(void*, int, int, const char*, ...);
            ]]
            
            
            local signature_gHud = "\xB9\xCC\xCC\xCC\xCC\x88\x46\x09"
            local signature_FindElement = "\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x57\x8B\xF9\x33\xF6\x39\x77\x28"
            
            -- find signature_gHud in client_panorama.dll
            local match = client.find_signature("client_panorama.dll", signature_gHud) or error("sig1 not found") -- returns void***
            -- cast the match from find_signature to a char* so it can be used for addition and add 1 to it
            local char_match = ffi.cast("char*", match) + 1 
            -- cast match + 1 back to a void***, so it can be dereferenced to get its vtable
            local hud = ffi.cast("void**", char_match)[0] or error("hud is nil") -- returns void**
            
            -- find signature_FindElement in client_panorama.dll
            match = client.find_signature("client_panorama.dll", signature_FindElement) or error("FindHudElement not found")
            -- cast the lightuserdata to a type that we can dereference
            local find_hud_element = ffi.cast("FindHudElement_t", match)
            -- use the returned cfunc find_hud_element with the parameter hud and "CHudChat" to get the CHudChat class pointer
            local hudchat = find_hud_element(hud, "CHudChat") or error("CHudChat not found")
            -- dereference the pointer to get its vtable
            local chudchat_vtbl = hudchat[0] or error("CHudChat instance vtable is nil")
            
            -- vtable is an array of functions, the 27th is ChatPrintf
            local raw_print_to_chat = chudchat_vtbl[27] -- void*
            
            -- cast the function pointer to a callable type
            local print_to_chat = ffi.cast('ChatPrintf_t', raw_print_to_chat)

            local function Send(text)
                print_to_chat(hudchat, 0, 0, text)
            end

            C['Libs']['ChatPrint']['Send'] = Send
        end
    },
    ['URLEncoder'] = {
        -- from https://gist.github.com/qpSHiNqp/84cda00abbba350f20a2
        ['Initialise'] = function()
            C['Libs']['URLEncoder']['Encode'] = function(str)
                if (not str) then
                    return str
                end
    
                str = string.gsub (str, "\n", "\r\n")
                str = string.gsub (str, "[^%w.%-_~]",
                    function (c) return string.format ("%%%02X", string.byte(c)) end)
    
                return str
            end

            C['Libs']['URLEncoder']['Decode'] = function(str)
                str = string.gsub(str, "%%([0-9a-fA-F][0-9a-fA-F])",
                    function (c) return string.char(tonumber("0x" .. c)) end)
                str = string.gsub (str, "\n", "\r\n")
                return str
            end
        end
    }
}

for _, lib in pairs(C['Libs']) do
    lib['Initialise']()
end

C['ChangeLogs'] = {
    '',
    '===== 1.10 (Apr 21 2020) =====',
    'Updated for latest update',
    'Removed json library & replaced with skeets inbuilt one',
    'Added option to enable chat translating [if you don\'t want to translate chat msgs but still use stuff like .tsay] [also should lower rate limit speed]',
    'Changed how discord messages display the profile url [removed the shitty embeds it creates]',
    'Fixed typos',
    'Fixed shit post not working',
    'Fixed discord messages from looking like shit if there was no one on enemy team'
}

C['Codes'] = [[

Afrikaans - af
Irish - ga
Albanian - sq
Italian - it
Arabic - ar
Japanese - ja
Azerbaijani - az
Kannada - kn
Basque - eu
Korean - ko
Bengali - bn
Latin - la
Belarusian - be
Latvian - lv
Bulgarian - bg
Lithuanian - lt
Catalan - ca
Macedonian - mk
Chinese Simplified - zh-CN
Malay - ms
Chinese Traditional - zh-TW
Maltese - mt
Croatian - hr
Norwegian - no
Czech - cs
Persian - fa
Danish - da
Polish - pl
Dutch - nl
Portuguese - pt
English - en
Romanian - ro
Esperanto - eo
Russian - ru
Estonian - et
Serbian - sr
Filipino - tl
Slovak - sk
Finnish - fi
Slovenian - sl
French - fr
Spanish - es
Galician - gl
Swahili - sw
Georgian - ka
Swedish - sv
German - de
Tamil - ta
Greek - el
Telugu - te
Gujarati - gu
Thai - th
Haitian Creole - ht
Turkish - tr
Hebrew - iw
Ukrainian - uk
Hindi - hi
Urdu - ur
Hungarian - hu
Vietnamese - vi
Icelandic - is
Welsh - cy
Indonesian - id
Yiddish - yi
]]

C['Colours'] = {
    ['White']           = '\x01',
    ['Red']             = '\x02',
    ['Purple']          = '\x03',
    ['Green']           = '\x04',
    ['YellowGreen']     = '\x05',
    ['LightGreen']      = '\x06',
    ['LightRed']        = '\x07',
    ['Gray']            = '\x08',
    ['LightYellow']     = '\x09',
    ['Gray2']           = '\x0A',
    ['Blue']            = '\x0B',
    ['DarkBlue']        = '\x0C',
    ['Gold']            = '\x10',
    ['RGB'] = {
        ['White'] = {
            ['r'] = 255,
            ['g'] = 255,
            ['b'] = 255
        },
        ['Yellow'] = {
            ['r'] = 234,
            ['g'] = 237,
            ['b'] = 37
        },
        ['Green'] = {
            ['r'] = 126,
            ['g'] = 215,
            ['b'] = 135
        },
        ['Red'] = {
            ['r'] = 200,
            ['g'] = 82,
            ['b'] = 76
        },
        ['Blue'] = {
            ['r'] = 105,
            ['g'] = 140,
            ['b'] = 255
        },
        ['Orange'] = {
            ['r'] = 200,
            ['g'] = 140,
            ['b'] = 56
        },
    }
}

--this is done so so so horrendously lmao
C['Notifications'] = {
    ['Send'] = function(var, bool, ...)
        local col = C['Colours']
        local cyrusText = col['White'] .. '[' .. col['Blue'] .. 'Cyrus' .. col['White'] .. '] ' .. col['Gold']
        local enabled = (bool and col['LightGreen'] .. 'Enabled' or col['LightRed'] .. 'Disabled')
        local str = ''

        local arg1, arg2, arg3 = ...

        local tab = ui['get'](C['UI']['Utilities']['Notification Type']['Element'])
        local hasValue = C['Funcs']['table.HasValue']

        if (not ...) then
            str = str .. col['White'] .. ' was ' .. enabled
            
            if (hasValue(tab, 'Chat Print')) then
                C['Libs']['ChatPrint']['Send'](cyrusText .. var .. str)
            end

            if (hasValue(tab, 'Console')) then
                C['Notifications']['ConsoleLog'](var .. str, bool, arg1, arg2)
            end
        elseif (arg2) then
            str = str .. col['White'] .. arg1

            if (hasValue(tab, 'Chat Print')) then
                C['Libs']['ChatPrint']['Send'](cyrusText .. var .. str)
            end

            if (hasValue(tab, 'Console')) then
                C['Notifications']['ConsoleLog'](var .. str, bool, arg1, arg2)
            end
        elseif (arg1) then
            str = str .. col['White'] .. ' (' .. col['Purple'] .. arg1 .. col['White'] .. ') was ' .. enabled

            if (hasValue(tab, 'Chat Print')) then
                C['Libs']['ChatPrint']['Send'](cyrusText .. var .. str)
            end

            if (hasValue(tab, 'Console')) then
                C['Notifications']['ConsoleLog'](var .. str, bool, arg1, arg2)
            end
        end
    end,
    ['ConsoleLog'] = function(var, bool, ...)
        local col = C['Colours']['RGB']
        local green = col['Green']
        local white = col['White']
        local blue = col['Blue']
        local red = col['Red']
        local orange = col['Orange']

        local log = client['color_log']

        log(white['r'], white['g'], white['b'], '[\0')
        log(blue['r'], blue['g'], blue['b'], 'Cyrus\0')
        log(white['r'], white['g'], white['b'], '] \0')
        log(white['r'], white['g'], white['b'], '- \0')

        local arg1, arg2 = ...

        if (arg2) then
            log(white['r'], white['g'], white['b'], var .. ' ')
        elseif (bool) then
            log(green['r'], green['g'], green['b'], var .. ' ')
        elseif (not bool) then
            log(red['r'], red['g'], red['b'], var .. ' ')
        end
    end,
    ['ConsoleHelpLog'] = function(var, bool, args, ...)
        local col = C['Colours']['RGB']
        local green = col['Green']
        local white = col['White']
        local blue = col['Blue']
        local red = col['Red']
        local orange = col['Orange']

        local log = client['color_log']

        if (bool) then
            log(white['r'], white['g'], white['b'], '[\0')
            log(blue['r'], blue['g'], blue['b'], 'Cyrus\0')
            log(white['r'], white['g'], white['b'], '] \0')

            log(green['r'], green['g'], green['b'], var .. ' ')
        else
            log(orange['r'], orange['g'], orange['b'], '\t ' .. var .. '\0')
            log(white['r'], white['g'], white['b'], ' ' .. (#args >= 1 and '-' or '' ) .. ' \0')
            log(green['r'], green['g'], green['b'], args .. ' ')
        end
    end
}

C['P'] = {
    ['MyPersonaAPI'] = C['JS']['Open']['MyPersonaAPI'],
    ['LobbyAPI'] = C['JS']['Open']['LobbyAPI'],
    ['PartyListAPI'] = C['JS']['Open']['PartyListAPI'],
    ['MatchInfoAPI'] = C['JS']['Open']['MatchInfoAPI'],
    ['GameStateAPI'] = C['JS']['Open']['GameStateAPI']
}

C['ConCmd'] = {
    ['Cmds'] = {
        ['help'] = {
            ['Func'] = function(str)
                local log = C['Notifications']['ConsoleHelpLog']
                log('The following commands are available:', true, '')

                for cmd, v in pairs(C['ConCmd']['Cmds']) do
                    log(cmd, false, v['Usage'])
                end

                log('', false, '')
            end,
            ['Usage'] = ''
        },
        ['id'] = {
            ['Func'] = function(str)
                if (str[2] == nil or str[2] == '' or #str[2] < 15) then
                    C['Notifications']['ConsoleLog']('Invalid use, exmaple usage: cyrus_id 123456789012345', false, '', '')
                else
                    C['Notifications']['ConsoleLog']('Set your discord acc id to: ' .. str[2], false, '', '')
                    database['write'](C['DB']['Ping']['ID'], str[2])
                end
            end,
            ['Usage'] = '<your discord id here>'
        },
        ['webhook'] = {
            ['Func'] = function(str)
                if (str[2] == nil or str[2] == '' or #str[2] < 20) then
                    C['Notifications']['ConsoleLog']('Invalid use, exmaple usage: cyrus_webhook https://discordapp.com/api/webhooks/xxxxxxxxxxx/xxxxxxxxxxxxxxxx-xxxx', false, '', '')
                else
                    C['Notifications']['ConsoleLog']('Set your discord channel webhook to: ' .. str[2], false, '', '')
                    database['write'](C['DB']['Ping']['Webhook'], str[2])
                end
            end,
            ['Usage'] = '<channel webhook here>'
        },
        ['webhook_end'] = {
            ['Func'] = function(str)
                if (str[2] == nil or str[2] == '' or #str[2] < 20) then
                    C['Notifications']['ConsoleLog']('Invalid use, exmaple usage: cyrus_webhook_end https://discordapp.com/api/webhooks/xxxxxxxxxxx/xxxxxxxxxxxxxxxx-xxxx', false, '', '')
                else
                    C['Notifications']['ConsoleLog']('Set your discord channel webhook to: ' .. str[2], false, '', '')
                    database['write'](C['DB']['Ping']['WebhookEnd'], str[2])
                end
            end,
            ['Usage'] = '<channel webhook here>'
        },
        ['psay'] = {
            ['Func'] = function(tab)
                if (tab[2] == nil or tab[2] == '') then
                    C['Notifications']['ConsoleLog']('Invalid use, exmaple usage: cyrus_psay Hello World!', false, '', '')
                else
                    local str = ''

                    for _, v in pairs(tab) do
                        str = str .. v .. ' '
                    end

                    C['Funcs']['PartyChatSay'](str)
                end
            end,
            ['Usage'] = '<text here>'
        },
        ['tsay'] = {
            ['Func'] = function(tab)
                if (ui['get'](C['UI']['Other']['Translator']['Element'])) then
                    if (not C['Vars']['Translator']['OnCD']) then
                        if (tab[2] == nil or tab[2] == '') then
                            C['Notifications']['ConsoleLog']('Invalid use, exmaple usage: cyrus_tsay Hello World!', false, '', '')
                        else
                            local str = ''

                            for _, v in pairs(tab) do
                                str = str .. v .. ' '
                            end

                            C['Funcs']['DoChatTranslation'](str, false, true)
                        end
                    else
                        C['Notifications']['ConsoleLog']('You\'re currently rate limited & cannot use this.', false, '', '')
                    end
                else
                    C['Notifications']['ConsoleLog']('You have the translator disabled.', false, '', '')
                end
            end,
            ['Usage'] = '<text to translate>'
        },
        ['translate_codes'] = {
            ['Func'] = function(tab)
                print(C['Codes'])
            end,
            ['Usage'] = ''
        }
    }
}

C['DB'] = {
    ['Ping'] = {
        ['ID'] = 'cyrus.ping.id',
        ['Webhook'] = 'cyrus.ping.webhook',
        ['WebhookEnd'] = 'cyrus.ping.webhookend'
    }
}

C['Ranks'] = {
    ['MM'] = {
        'SI',
        'S2',
        'S3',
        'S4',
        'SE',
        'SEM',

        'GN1',
        'GN2',
        'GN3',
        'GNM',
        'MG1',
        'MG2',

        'MGE',
        'DMG',
        'LE',
        'LEM',
        'SMFC',
        'GE'
    },
    ['DZ'] = {
        'Lab Rat I',
        'Lab Rat II',
    
        'Sprinting Hare I',
        'Sprinting Hare II',
    
        'Wild Scout I',
        'Wild Scout II',
        'Wild Scout Elite',
    
        'Hunter Fox I',
        'Hunter Fox II',
        'Hunter Fox III',
        'Hunter Fox Elite',
    
        'Timber Wolf',
        'Ember Wolf',
        'Wildfire Wolf',
    
        'The Howling Alpha'
    }
}

-- credits to LegendOfRobbo for the shit post in here
C['Chat'] = {
    ['CmdPrefix'] = '!',
    ['Commands'] = {
        ['buy'] = {
            ['Func'] = function(args, speaker)
                local speakerTeam =  C['Funcs']['GetTeam'](speaker)
                local me = entity['get_local_player']()
                local myTeam =  C['Funcs']['GetTeam'](me)

                if (speakerTeam == myTeam and speaker ~= me) then
                    if (ui['get'](C['UI']['MM']['AFK Buy-Drop']['Element'])) then
                        if (args) then
                            local wep = args[2]

                            if (#wep >= 2 and #wep <= 8) then
                                local base = C['Vars']['BuyBot']['WeaponData'][wep]
                                local mode = C['Funcs']['GetChatMode']()
                                local cmd = client['exec']

                                if (base) then
                                    local money = C['Funcs']['GetMoney'](entity['get_local_player']())
                                    local ent, cost = base['ent'], base['cost']

                                    if (money >= cost) then
                                        cmd('buy ', ent)

                                        client['delay_call'](1, function()
                                            cmd('slot0')

                                            client['delay_call'](0, function()
                                                cmd('drop')
                                            end)
                                        end)
                                    else
                                        cmd(mode, 'I\'m too much of a poor fag to afford it :^(')
                                    end
                                else
                                    cmd(mode, 'Invalid weapon name provided \'' .. wep .. '\'')
                                end
                            end
                        end
                    end
                end
            end
        },
    },
    ['Spam'] = {
        ['LastChatMessage'] = globals['tickcount'](),
        ['LastRadioMessage'] = globals['tickcount'](),
        ['RadioMessage'] = 'getout',
        ['DefaultMessage'] = 'your tears are currently being harvested',
        ['Types'] = {
            ['Kill'] = 'Off',
            ['Death'] = 'Off',
            ['Chat'] = 'Off'
        }
    },
    ['Words'] = {
        ['Openers'] = {
            'get fucked',
            'eat shit',
            'fuck a baboon',
            'suck my dingleberries',
            'choke on steaming cum',
            'die in a fire',
            'gas yourself',
            'sit on garden shears',
            'choke on scrotum',
            'shove a brick up your ass',
            'swallow barbed wire',
            'move to sweden',
            'fuck a pig',
            'bow to me',
            'suck my ball sweat',
            'come back when you aren\'t garbage',
            'i will piss on everything you love',
            'kill yourself',
            'livestream suicide',
            'neck yourself',
            'go be black somewhere else',
            'rotate on it',
            'choke on it',
            'blow it out your ass',
            'go browse tumblr',
            'go back to casual',
            'sit on horse cock',
            'drive off a cliff',
            'rape yourself',
            'get raped by niggers',
            'fuck right off',
            'you mother is a whore',
            'come at me',
            'go work the corner',
            'you are literal cancer',
            'why haven\'t you killed yourself yet',
            'why do you even exist',
            'shoot your balls off with a shotgun',
            'sterilize yourself',
            'convert to islam',
            'drink bleach',
            'remove yourself',
            'choke on whale cock',
            'suck shit',
            'suck a cock',
            'lick my sphincter',
            'set yourself on fire',
            'drink jenkem',
            'get beaten to death by your dad',
            'choke on your uncle\'s cock',
            'get sat on by a 200kg feminist',
            'blow off',
            'join isis',
            'stick your cock in a blender',
            'OD yourself on meth',
            'lie under a truck',
            'lick a wall socket',
            'swallow hot coals',
            'die slowly',
            'explode yourself',
            'swing from the noose',
            'end yourself',
            'take your best shot',
            'get shot in a gay bar',
            'drink pozzed cum',
            'marry a muslim',
            'rub your dick on a cheese grater',
            'wrap a rake with barbed wire and sodomize yourself',
            'close your gaping cunt',
        },
        ['Joiners'] = {
            'cancer infested',
            'cock sucking',
            'fuck faced',
            'cunt eyed',
            'nigger fucking',
            'candy ass',
            'fairy ass fucking',
            'shit licking',
            'unlovable',
            'disgusting',
            'degenerate',
            'fuck headed',
            'dick lipped',
            'autismal',
            'gook eyed',
            'mongoloided',
            'cunt faced',
            'dick fisted',
            'worthless',
            'hillary loving',
            'maggot infested',
            'boot lipped',
            'chink eyed',
            'shit skinned',
            'nigger headed',
            'lgbt supporting',
            'cum stained',
        },
        ['Enders'] = {
            'fuck face',
            'poofter',
            'jew cunt',
            'fagmaster',
            'goat rapist',
            'rag head',
            'cock cheese',
            'vaginaphobe',
            'coon',
            'nigger',
            'slag cunt',
            'garbage man',
            'paeodophile',
            'kiddy toucher',
            'pony fucker',
            'tumblrite',
            'sperglord',
            'gorilla\'s dick',
            'shit licker',
            'shit slick',
            'redditor',
            'pig fucker',
            'spastic',
            'cuckold',
            'chode gobbler',
            'fuckwit',
            'retard',
            'mongoloid',
            'elephants cunt',
            'cunt',
            'gook',
            'fag lord',
            'shit stain',
            'mpgh skid',
            'batch coder',
            'pony fucker',
            'furfag',
            'half caste',
            'double nigger',
            'cock socket',
            'cunt rag',
            'anal wart',
            'maggot',
            'knob polisher',
            'fudge packer',
            'cock slave',
            'trashmaster',
            'shitskin',
            'curry muncher',
            'gator bait',
            'bootlip',
            'camel jockey',
            'wog cunt',
            'hooknosed kike',
            'feminist',
            'wop cunt',
            'abo',
            'porch monkey',
            'dago',
            'anal secretion',
            'pig cunt',
            'insect',
            'sub human',
            'mental defect',
            'fat whore',
            'cunt rag',
            'cotton picker',
            'bum tickling fag',
            'degenerate faggot',
            'smegma lump',
            'darkie',
            'fuck toy',
            'underage midget cunt',
            'twelvie',
            'faggot teenager',
            'ankle biter',
            'fat cunt american',
            'bernie loving washout',
            'fucking failure',
            'cum dumpster',
            'waste of skin',
            'petrol sniffing coon',
            'jenkem bottle',
            'dirty jew',
            'casual retard',
            'cuck master',
            'barrel of piss',
            'tankard of shit',
            'cock wart',
        },
        ['CancerStrike'] = {
            'LOL fuk u silver scUm',
            'nice aim doEs It cume in NOT N00be?',
            'u r terible my doode',
            'u almost hit me that time LOL',
            'ur aim iz a joke my man',
            'get shrekt skrub xdddd',
            'u just got shitted on kidddd',
            'i bet u r silver on csgo xD',
            'u never stood a chance against my pSkillz',
            'ur just 2bad to kill me :^(',
            'dam im good',
            'u wil never beat aimware hax kidd :^)',
            'eat shit and die xdd',
            'i laugh at ur shit skillz :D',
            'get fukn owned kid xd',
            'i kill u every time u shud try harder :^(',
            'all u can do is die LOL',
            'N00bez like u cant beat me LOL',
            'u tried but im jus 2 gud 4 u',
            'u cant even hit me LOL uninstall kid xd',
            'git GUD skrub u r an embarasment',
            'pathetic LOL',
            '2 bad so sad u just bad :^(',
            'im global elit in csgo xd',
            'thx 4 free kill loser :D',
            'r u even trying???',
            'top kekt u got rekt',
            'fuken smashed kunt :D',
            'u shud add me so i can teach u how 2 shoot LOL',
            'ur jus 2 weak and sad to beat me xd',
            'looks liek ur sad life isnt working out 2 well 4 u :D',
            'dats all u got??? LOL!',
        },
        ['SuperCancerStrike'] = {
            'dont upsetti hav some spagetti',
            'eat my asse like a bufet (3 corse meal xd)',
            'i ownt u in ur gay butth0le',
            'umade noobe?',
            'le troled hard',
            'go wach naturo and play wif urself fag REKT',
            'LOL i fuckd u so hard just like ur mum lst nit fag',
            'u play liek a blynd stefen hawkin haha',
            'ARE U GUEYS NEW??',
            'are u as bad at life as u are in csgo??',
            'omg this is 2 ezy are U even trying??',
            'why dont u go play halo an fist ur butthol faget',
            'hey granma is that u???? LOL so bad',
            'time for you 2 uninstale the game shit stane',
            'congrtulations ur the worlds worst csgo player',
            'dose ur aim come in NOT NOOBE? LMAO',
            'lol i troled u so hard *OWNED*',
            '\'i lik 2 eat daddys logs of poo for lucnh while jackn off 2 naturo\'- u',
            'take a se4t faget $hitstain u got OWNDE',
            'LOL scrub ur gettin rekt hardcroe',
            'R u mad becouse ur bad nooby?',
            'LMAO did u go to da buthurt king an g3t urself a butthurt with fries?!?',
            'why dont u go and play manoppoly you noob',
            'you hav no lyfe you cant evan play csgo propaly',
            'im hi rite now on ganj but im stil ownen u xD',
            'if u want my cum bake ask ur mum LOL',
            'butdocter prognoses: OWND',
            'cry 2 ur dads dick forver noob',
            'lol troled autismal faget',
            'LOL N3RD owned',
            '\'i love to drink sprems all day\'- u',
            'crushd nerd do u want a baindaid for that LOL',
            'lol rectal rekage ur so sh1t lol',
            'ass states - [_] NOT REKT [X] REKT',
            'lmao do u even try????',
            'are u slippan off ur chaire cos ur ass is bleeding so hard??',
            'u better get a towel for all ur tears faget',
            'u got ass asassenated by me rofl',
            'u wont shit agen thats how rekt ur ass is',
            'i bet youre anus is sore from me ownen u LOL',
            'im gonna record a fragshow so i can watch me pwn u ova and ova LMAO',
            'i almost feel sorry for you hahahaha',
            'lol why dont u play COD so i can own you there too',
            'how dose it feel to be owneded so hartd??',
            'rekt u lol another one for the fraghsow',
            'if i was as bade as u i would kil myself',
            'dont fell bad not ervry one can be goode',
            'do u need some loob for ur butt so it doesnt hurt so much when i fuck u',
            'spesciall delivary for CAPTEN BUTTHURT',
            'wats wrong cant play wif ur dads dik in ur mouth????',
            'maybe if u put down the cheseburgers u could kill me lol fat nerd',
            'getting mad u virgan nerd??',
            'butt docta prognosis: buttfustrated',
            '<<< OWEND U >>>',
            'if u were a fish you wuld be a sperm whael LOL',
            '>mfw i ownd u',
            'rekt u noob *OWNED*',
            'ur gonna have 2 wear dipers now cos ur ass got SHREDED by me',
            'y dont u take a short strole to the fagot store and buy some skills scrub',
            'school3d by a 13yo lol u r rely bad',
            'ur pathetic nerd its like u have parkensons',
            'u just got promoted 2 cumcaptain prestige',
            'lol pwnd',
            'u just got butt raped lol TROLLED U',
            'did u learn 2 aim from stevie wondar??? LOL',
            'tell ur mum to hand the keyboard and mosue back',
            'how does it feel to be shit on by a 13 yer old',
            'r u into scat porns or some thing cos it feel\'s like u want me 2 shit on u',
            'u play csgo like my granpa and hes ded',
            'are u new or just bad?? noobe',
            'u play csgo lik a midget playin basket ball',
            'welcome to the noob scoole bus first stop ur house <<PWND>>',
            '>mfw i rek u',
            '\'i got my ass kiked so hard im shittn out my mouf\' - u',
            '<-(0.0)-<   dats u gettn ownd LOL',
            'u just got ur ass ablitterated <<<RECKT>>>',
            'c=3 (dats ur tiney dik rofl)',
            'just leeve the game and let the real mans play',
            'ur so bad u make ur noobe team look good',
            'CONGRASTULATIONS YOU GOT FRIST PRIZE IN BEING BUTT MAD (BUT LAST IN PENIS SIZE LMAO)',
            'im not even trying to pwn u its just so easy',
            'im only 13 an im better than u haha XD',
            'u just got raped',
            'some one an ambulance cos u just got DE_STROYED',
            'i hope u got birth control coz u got rapped',
            'lol pwnd scrubb',
            'you play lik a girl',
            '\'i got fukd so hard dat im cummin shit n shittn cum\'- u',
            'ur gonna need tampons for ur ass afta that ownage',
            '{{ scoooled u }}',
            '(O.o) ~c======3 dats me jizzan on u',
            'dont worry at least ur tryan XD',
            'cya noob send me a post card from pwnd city ROFL',
            'its ok if u keep practasing u will get bettar lol #rekt',
            '\'evry time i fart 1 liter of cum sqerts out\' - u',
            'rofl i pwnd u scrub #420 #based #mlgskill',
            'u fail just like ur dads condom',
            'if i pwnd u any harder it wud be animal abuse',
            'uploaden this fragshow roflmao',
        },
        ['AnnoyingQuestions'] = {
            'whats the max tabs you can have open on a vpn',
            'whats the time',
            'is it possible to make a clock in binary',
            'how many cars can you drive at once',
            'did you know there\'s more planes on the ground than there is submarines in the air',
            'how many busses can you fit on 1 bus',
            'how many tables does it take to support a chair',
            'how many doors does it take to screw a screw',
            'how long can you hold your eyes closed in bed',
            'how long can you hold your breath for under spagetti',
            'whats the fastest time to deliver the mail as a mail man',
            'how many bees does it take to make a wasp make honey',
            'If I paint the sun blue will it turn blue',
            'how many beavers does it take to build a dam',
            'how much wood does it take to build a computer',
            'can i have ur credit card number',
            'is it possible to blink and jump at the same time',
            'did you know that dinosaurs were, on average, large',
            'how many thursdays does it take to paint an elephant purple',
            'if cars could talk how fast would they go',
            'did you know theres no oxygen in space',
            'do toilets flush the other way in australia',
            'if i finger paint will i get a splinter',
            'can you build me an ant farm',
            'did you know australia hosts 4 out of 6 of the deadliest spiders in the world',
            'is it possible to ride a bike in space',
            'can i make a movie based around your life',
            'how many pants can you put on while wearing pants',
            'if I paint a car red can it wear pants',
            'how come no matter what colour the liquid is the froth is always white',
            'can a hearse driver drive a corpse in the car pool lane',
            'how come the sun is cold at night',
            'why is it called a TV set when there is only one',
            'if i blend strawberries can i have ur number',
            'if I touch the moon will it be as hot as the sun',
            'did u know ur dad is always older than u',
            'did u know the burger king logo spells burger king',
            'did u know if u chew on broken glass for a few mins, it starts to taste like blood',
            'did u know running is faster than walking',
            'did u know the colour blue is called blue because its blue',
            'did u know a shooting star isnt a star',
            'did u know shooting stars dont actually have guns',
            'did u know the great wall of china is in china',
            'statistictal fact: 100% of non smokers die',
            'did u kmow if you eat you poop it out',
            'did u know rain clouds r called rain clouds cus they are clouds that rain',
            'if cows drink milk is that cow a cannibal',
            'did u know you cant win a staring contest with a stuffed animal',
            'did u know if a race car is at peak speed and hits someone they\'ll die',
            'did u know the distance between the sun and earth is the same distance as the distance between the earth and the sun',
            'did u know flat screen tvs arent flat',
            'did u know aeroplane mode on ur phone doesnt make ur phone fly',
            'did u know too many birthdays can kill you',
            'did u know rock music isnt for rocks',
            'did u know if you eat enough ice you can stop global warming',
            'if ww2 happened before vietnam would that make vietnam world war 2',
            'did u know 3.14 isn\'t a real pie',
            'did u know 100% of stair accidents happen on stairs',
            'can vampires get AIDS',
            'what type of bird was a dodo',
            'did u know dog backwards is god',
            'did you know on average a dog barks more than a cat',
            'did u know racecar backwards is racecar'
        }
    }
}

C['Vars'] = {
    ['TeamKillData'] = {},
    ['HitLog'] = {
        ['Hit Groups'] = {
            [0] = 'Body',
            'Head',
            'Chest',
            'Stomach',
            'Left Arm',
            'Right Arm',
            'Left Leg',
            'Right Leg',
            'Neck',
            '?',
            'Gear'
        },
        ['Hit'] = {},
        ['ShotInfo'] = {},

    },
    ['BuyBot'] = {
        ['WeaponData'] = {
            ['glock'] = {
                ['ent'] = 'glock',
                ['cost'] = 200
            },
            ['p2k'] = {
                ['ent'] = 'hkp2000',
                ['cost'] = 200
            },
            ['p2000'] = {
                ['ent'] = 'hkp2000',
                ['cost'] = 200
            },
            ['usp'] = {
                ['ent'] = 'usp_silencer',
                ['cost'] = 200
            },
            ['dualies'] = {
                ['ent'] = 'elite',
                ['cost'] = 400
            },
            ['p250'] = {
                ['ent'] = 'p250',
                ['cost'] = 300
            },
            ['tec9'] = {
                ['ent'] = 'tec9',
                ['cost'] = 500
            },
            ['57'] = {
                ['ent'] = 'fn57',
                ['cost'] = 500
            },
            ['deagle'] = {
                ['ent'] = 'deagle',
                ['cost'] = 700
            },
            ['r8'] = {
                ['ent'] = 'deagle',
                ['cost'] = 600
            },



            ['galil'] = {
                ['ent'] = 'galilar',
                ['cost'] = 2000
            },
            ['famas'] = {
                ['ent'] = 'famas',
                ['cost'] = 2050
            },
            ['ak'] = {
                ['ent'] = 'ak47',
                ['cost'] = 2700
            },
            ['ak47'] = {
                ['ent'] = 'ak47',
                ['cost'] = 2700
            },
            ['ak-47'] = {
                ['ent'] = 'ak47',
                ['cost'] = 2700
            },
            ['m4a4'] = {
                ['ent'] = 'm4a1',
                ['cost'] = 3100
            },
            ['m4a1'] = {
                ['ent'] = 'm4a1_silencer',
                ['cost'] = 2900
            },
            ['scout'] = {
                ['ent'] = 'ssg08',
                ['cost'] = 1700
            },
            ['ssg'] = {
                ['ent'] = 'ssg08',
                ['cost'] = 1700
            },
            ['aug'] = {
                ['ent'] = 'aug',
                ['cost'] = 3300
            },
            ['sg553'] = {
                ['ent'] = 'sg556',
                ['cost'] = 3000
            },
            ['sg'] = {
                ['ent'] = 'sg556',
                ['cost'] = 3000
            },
            ['awp'] = {
                ['ent'] = 'awp',
                ['cost'] = 4750
            },
            ['dak'] = {
                ['ent'] = 'scar20',
                ['cost'] = 5000
            },
            ['auto'] = {
                ['ent'] = 'scar20',
                ['cost'] = 5000
            },



            ['nova'] = {
                ['ent'] = 'nova',
                ['cost'] = 1050
            },
            ['xm10'] = {
                ['ent'] = 'xm1014',
                ['cost'] = 2000
            },
            ['sawedoff'] = {
                ['ent'] = 'mag7',
                ['cost'] = 1100
            },
            ['mag7'] = {
                ['ent'] = 'mag7',
                ['cost'] = 1300
            },
            ['m249'] = {
                ['ent'] = 'm249',
                ['cost'] = 5200
            },
            ['negev'] = {
                ['ent'] = 'negev',
                ['cost'] = 1700
            },
            


            ['mac10'] = {
                ['ent'] = 'mac10',
                ['cost'] = 1050
            },
            ['mp9'] = {
                ['ent'] = 'mp9',
                ['cost'] = 1250
            },
            ['mp7'] = {
                ['ent'] = 'mp7',
                ['cost'] = 1500
            },
            ['ump'] = {
                ['ent'] = 'ump45',
                ['cost'] = 1200
            },
            ['p90'] = {
                ['ent'] = 'p90',
                ['cost'] = 2350
            },
            ['bizon'] = {
                ['ent'] = 'bizon',
                ['cost'] = 1400
            }
        }
    },
    ['UseSpam'] = {
        ['LastSwap'] = globals['tickcount'](),
        ['Swap'] = false
    },
    ['Translator'] = {
        ['OnCD'] = false,
        ['CDTimer'] = 300
    }
}

-- credits to sapphyrus for the not shit vote handling
C['Votes'] = {
    ['IndicesNoteam'] = {
        [0] = "kick",
        [1] = "changelevel",
        [3] = "scrambleteams",
        [4] = "swapteams",
    },
    ['IndicesTeam'] = {
        [1] = 'starttimeout',
        [2] = 'surrender'
    },
    ['Descriptions'] = {
        ['changelevel'] = 'change the map',
        ['scrambleteams'] = 'scramble the teams',
        ['starttimeout'] = 'start a timeout',
        ['surrender'] = 'surrender',
        ['kick'] = 'kick'
    },

    ['OnGoingVotes'] = {},
    ['VoteOptions'] = {}
}

C['Funcs'] = {
    ['PrintChangelogs'] = function()
        local col = C['Colours']['RGB']
        local green = col['Green']
        local white = col['White']
        local blue = col['Blue']
        local red = col['Red']
        local orange = col['Orange']

        local log = client['color_log']
        
        log(white['r'], white['g'], white['b'], '[\0')
        log(blue['r'], blue['g'], blue['b'], 'Cyrus\0')
        log(white['r'], white['g'], white['b'], '] - \0')
        log(orange['r'], orange['g'], orange['b'], 'by x0m\0')

        for _, v in pairs(C['ChangeLogs']) do
            if (v:sub(1,1) == '=') then
                log(red['r'], red['g'], red['b'], '\t' .. v .. ' ')
            elseif (v ~= '') then
                log(green['r'], green['g'], green['b'], '\t• ' .. v .. ' ')
            else
                log(green['r'], green['g'], green['b'], ' ')
            end
        end
    end,
    ['GetShitPost'] = function(type)
        local rand = C['Funcs']['table.Random']

        if (type == 'Insult') then
            local words = C['Chat']['Words']
            return rand(words['Openers']) .. ' you ' .. rand(words['Joiners']) .. ' ' .. rand(words['Enders'])
        elseif (type == 'Insult (Caps)') then
            local words = C['Chat']['Words']
            return string['upper'](rand(words['Openers']) .. ' you ' .. rand(words['Joiners']) .. ' ' .. rand(words['Enders']))
        elseif (type == 'Cancer Strike') then
            return rand(C['Chat']['Words']['CancerStrike'])
        elseif (type == 'Super Cancer Strike') then
            return rand(C['Chat']['Words']['SuperCancerStrike'])
        else
            return rand(C['Chat']['Words']['AnnoyingQuestions'])
        end
    end,
    ['table.Random'] = function(table)
        return table[ client['random_int'](1, #table) ]
    end,
    ['table.HasValue'] = function(table, value)
        if (type(table) ~= 'table') then
            return false
        end

        for _, v in pairs(table) do
            if (value == v) then
                return true
            end
        end

        return false
    end,
    ['string.Explode'] = function(separator, str)
        local ret = {}
        local currentPos = 1
    
        for i = 1, #str do
            local startPos, endPos = string['find'](str, separator, currentPos)
            if ( not startPos ) then break end
            ret[ i ] = string['sub']( str, currentPos, startPos - 1 )
            currentPos = endPos + 1
        end
    
        ret[#ret + 1] = string['sub']( str, currentPos )
    
        return ret
    end,
    ['GetPlayerProperty'] = function(property, index)
        return entity['get_prop'](entity['get_player_resource'](), property, index)
    end,
    ['GetProperty'] = function(property, index, ...)
        return (... and entity['get_prop'](index, property, ...) or entity['get_prop'](index, property))
    end,
    ['IsConnected'] = function(index)
        return C['Funcs']['GetPlayerProperty']('m_bConnected', index) == 1
    end,
    ['IsBot'] = function(index)
        local base = C['Funcs']['GetPlayerProperty']
        return base('m_iBotDifficulty', index) >= 0 and base('m_iBotDifficulty', index) <= 4
    end,
    ['IsHuman'] = function(index)
        return C['Funcs']['GetPlayerProperty']('m_iBotDifficulty', index) == -1
    end,
    ['GetTeam'] = function(index)
        return C['Funcs']['GetPlayerProperty']('m_iTeam', index)
    end,
    ['GetCompWins'] = function(index)
        return C['Funcs']['GetPlayerProperty']('m_iCompetitiveWins', index)
    end,
    ['GetCompRank'] = function(index)
        local rankID = C['Funcs']['GetPlayerProperty']('m_iCompetitiveRanking', index)
        return (string['find'](globals['mapname'](), 'dz') and (C['Ranks']['DZ'][rankID] or 'unranked') or (C['Ranks']['MM'][rankID] or 'unranked'))
    end,
    ['GetChatMode'] = function()
        return (ui['get'](C['UI']['Utilities']['Team Only']['Element']) and 'say_team' or 'say') .. ' '
    end,
    ['GetChatDelay'] = function(i)
        return 1 * (i * 0.80) + (C['Funcs']['GetPlayerProperty']('m_iPing', entity['get_local_player']()) * 0.01) -- these doubles come out my ass but seem to be stable
    end,
    ['GetMoney'] = function(index)
        return C['Funcs']['GetProperty']('m_iAccount', index)
    end,
    ['IsValidChatCmd'] = function(text)
        return C['Chat']['Commands'][text:lower()]
    end,
    ['HasTaser'] = function(ent)
        for i = 0, 9 do
            if (entity['get_classname'](C['Funcs']['GetProperty']('m_hMyWeapons', ent, i)) == 'CWeaponTaser') then
                return true
            end
        end

        return false
    end,
    ['SteamID3To64'] = function(id)
        local y
        local z
        
        if ((id % 2) == 0) then
            y = 0
            z = (id / 2)
        else
            y = 1
            z = ((id - 1) / 2)
        end
        
        return '7656119' .. ((z * 2) + (7960265728 + y))
    end,
    ['IsValidConsoleCmd'] = function(text)
        return C['ConCmd']['Cmds'][text:lower()]
    end,
    ['GetTeamInitials'] = function(bool)
        local myTeam = C['Funcs']['GetTeam'](entity['get_local_player']())
        local enemyTeam = (myTeam == 3) and 2 or 3

        if (bool) then
            return myTeam == 3 and 'CT' or 'T'
        else
            return enemyTeam == 3 and 'CT' or 'T'
        end
    end,
    ['GetTeamRounds'] = function(bool)
        local myTeam = C['Funcs']['GetTeam'](entity['get_local_player']())
        local enemyTeam = (myTeam == 3) and 2 or 3
        local gameData = C['P']['GameStateAPI']['GetScoreDataJSO']()['teamdata']
        local team = ''

        if (bool) then
            team = myTeam == 3 and 'CT' or 'TERRORIST'
        else
            team = enemyTeam == 3 and 'CT' or 'TERRORIST'
        end

        return gameData[team]['score']
    end,
    ['StartPlayerTable'] = function(bool)
        local base = C['Funcs']
        local myTeam = base['GetTeam'](entity['get_local_player']())
        local str = ''
        local totalPlayers = 0

        for i = 0, globals['maxplayers']() do
            local playerTeam = base['GetTeam'](i)

            if ((playerTeam == 2 or playerTeam == 3) and base['IsConnected'](i)) then
                if (myTeam == playerTeam and bool) or (myTeam ~= playerTeam and not bool) then
                    local nick = entity['get_player_name'](i)
                    local rank = base['GetCompRank'](i)
                    local sid64 = base['SteamID3To64'](entity['get_steam64'](i))
                    local sid64Format = '<https://steamcommunity.com/profiles/' .. sid64 .. '/>'
                    local isBot = base['IsBot'](i)
        
                    if (isBot) then
                        str = str .. [[\n\t● ]] .. nick .. ' (BOT)'
                    else
                        str = str .. [[\n\t● ]] .. nick .. ' ([' .. sid64 .. '](' .. sid64Format .. ' )) ' .. '(' .. rank .. ')'
                    end

                    totalPlayers = totalPlayers + 1
                end
            end
        end

        if (totalPlayers == 0) then
            str = str .. [[\n\tn/a]]
        end
        
        return str .. [[\n\n]]
    end,
    ['EndPlayerTable'] = function(bool)
        local base = C['Funcs']
        local str = ''
        local arr = {}

        for i = 0, globals['maxplayers']() do
            local playerTeam = base['GetTeam'](i)
            local myTeam = base['GetTeam'](entity['get_local_player']())

            if ((playerTeam == 2 or playerTeam == 3) and base['IsConnected'](i)) then
                local score = base['GetPlayerProperty']('m_iScore', i)

                if (myTeam == playerTeam and bool) or (myTeam ~= playerTeam and not bool) then
                    table.insert(arr, {player = i, score = score})
                end
            end
        end

        table.sort(arr, function(a,b) return a.score > b.score end)

        for _, v in pairs(arr) do
            local i = v.player
            local nick = entity['get_player_name'](i)
            local rank = base['GetCompRank'](i)
            local sid64 = base['SteamID3To64'](entity['get_steam64'](i))
            local isBot = base['IsBot'](i)
            local kills = base['GetPlayerProperty']('m_iKills', i)
            local deaths = base['GetPlayerProperty']('m_iDeaths', i)
            local assists = base['GetPlayerProperty']('m_iAssists', i)
            local mvp = base['GetPlayerProperty']('m_iMVPs', i)
            local score = v.score

            if (isBot) then
                str = str .. [[\n\t● ]] .. nick .. ' (BOT)'
            else
                str = str .. [[\n\t● ]] .. nick .. ' ([' .. sid64 .. '](<https://steamcommunity.com/profiles/' .. sid64 .. '/>)) (' .. rank .. ')'
            end

            str = str .. ' (' .. kills .. '/' .. assists .. '/ ' .. deaths .. ') (mvp: ' .. mvp .. ' score: ' .. score .. ')'
        end

        if (#arr == 0) then
            str = str .. [[\n\tn/a]]
        end
        
       return str .. [[\n\n]]
    end,
    ['PartyChatSay'] = function(text)
        C['P']['PartyListAPI']['SessionCommand']('Game::Chat', 'run all xuid ' .. C['P']['MyPersonaAPI']['GetXuid']() .. ' chat ' .. text)
    end,
    ['DoChatTranslation'] = function(text, bool, me, toLang)
        local baseCD = C['Vars']['Translator']

        if (not baseCD['OnCD']) then
            local get = ui['get']
            local col = C['Colours']
            local baseTranslator = C['UI']['Other']['Translator']
            local baseHidden = baseTranslator['Hidden']
            local url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=' .. get(baseHidden['Source']) .. '&tl='

            local languageToTranslateTo = toLang or get(baseHidden['To'])

            if (bool) then
                url = url .. get(baseHidden['Local'])
            else
                url = url .. languageToTranslateTo
            end

            url = url .. '&dt=t&q=' .. C['Libs']['URLEncoder']['Encode'](text)

            if (ui['get'](baseTranslator['Hidden']['Incoming']['Element']) or me) then
                panorama['loadstring']([[
                    $.AsyncWebRequest(']] .. url .. [[', {type: 'GET', complete: function(c) {
                        cyrus_last_translation = c;
                    }});
                ]])()

                client['delay_call'](1, function()
                    local response = C['JS']['Funcs'].GetLastTranslation()

                    if (response['responseText'] and response['statusText'] ~= 'error') then
                        local txt = response['responseText']
                        local tab = json.parse(txt)
                        local translatedText = tab[1][1][1]
                        local fromText = tab[1][1][2]
                        local detectedLang = tab[9][1][1]

                        if (detectedLang ~= get(baseHidden['Local']) and bool) then
                            C['Notifications']['Send'](col['White'] .. '[' .. col['Red'] .. detectedLang .. col['White'] .. '] ' , true, translatedText, 'translate')
                        elseif (me) then
                            client['exec'](C['Funcs']['GetChatMode'](), translatedText)

                            if (get(baseTranslator['Element']) and get(baseTranslator['Hidden']['ShowOGMsg']['Element'])) then
                                client['delay_call'](0.1, function()
                                    C['Notifications']['Send'](col['White'] .. '[' .. col['Red'] .. 'og msg' .. col['White'] .. '] ' , true, fromText, 'translate')
                                end)
                            end
                        end
                    elseif (me) then
                        client['exec'](C['Funcs']['GetChatMode'](), text)
                        client['delay_call'](0.1, function()
                            C['Notifications']['Send'](col['White'] .. '[' .. col['Red'] .. 'translator' .. col['White'] .. '] ' , true, 'You\'re rate limited by google, sending normal message.', 'translate')
                        end)

                        ui['set'](baseTranslator['Hidden']['Outgoing']['Element'], false)
                    end
                end)
            end
        end
    end
}

C['UI'] = {
    ['Utilities'] = {
        ['Notification Type'] = {
            ['Element'] = ui['new_multiselect'](C['Config']['Panel'], C['Config']['Side'], 'Notification Type', {'Chat Print', 'Console'}),
            ['Callback'] = function(e)
                local msg = ''
                local col = C['Colours']
                local tab = ui['get'](e)

                if (#tab > 0) then
                    for _, v in pairs(tab) do
                        msg = msg .. col['Purple'] .. v .. col['White'] .. ', '
                    end

                    msg = msg:sub(1, #msg - 2)

                    C['Notifications']['Send']('Notification Type', true, msg)
                end
            end
        },
        ['AFK Mode'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'AFK Mode'),
            ['Callback'] = function(e)
                local bool = ui['get'](e)
                client['exec']((bool and '+' or '-') .. 'duck')

                C['Notifications']['Send']('AFK Mode', bool)
            end
        },
        ['Radio Spam'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Radio Spam'),
            ['Hidden'] = {
                ['Speed'] = ui['new_slider'](C['Config']['Panel'], C['Config']['Side'], 'Spam Delay', 50, 150, 70, true, '%')
            },
            ['Callback'] = function(e)
                local bool = ui['get'](e)
                ui['set_visible'](C['UI']['Utilities']['Radio Spam']['Hidden']['Speed'], bool)
                C['Notifications']['Send']('Radio Spam', bool)
            end
        },
        ['Vote Revealer'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Vote Revealer'),
            ['Callback'] = function(e)
                C['Notifications']['Send']('Vote Revealer', ui['get'](e))
            end
        },
        ['Team Only'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Team Only [chat msgs]'),
            ['Callback'] = function(e)
                C['Notifications']['Send']('Team Only', ui['get'](e))
            end
        },
        ['Use Spam'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Use Spam'),
            ['Hidden'] = {
                ['Speed'] = ui['new_slider'](C['Config']['Panel'], C['Config']['Side'], 'Spam Delay', 1, 100, 5, true, '%'),
                ['Key'] = ui['new_hotkey'](C['Config']['Panel'], C['Config']['Side'], 'Spam Key', true)
            },
            ['Callback'] = function(e)
                local bool = ui['get'](e)
                ui['set_visible'](C['UI']['Utilities']['Use Spam']['Hidden']['Speed'], bool)
                ui['set_visible'](C['UI']['Utilities']['Use Spam']['Hidden']['Key'], bool)
                C['Notifications']['Send']('Use Spam', bool)
            end
        },
        ['Plasma Shot'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Plasma Shot'),
            ['Hidden'] = {
                ['Key'] = ui['new_hotkey'](C['Config']['Panel'], C['Config']['Side'], 'Key', true)
            },
            ['Callback'] = function(e)
                local bool = ui['get'](e)
                ui['set_visible'](C['UI']['Utilities']['Plasma Shot']['Hidden']['Key'], bool)
                C['Notifications']['Send']('Plasma Shot', bool)
            end
        },
        ['Auto Leave'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Auto DC [end of game]'),
            ['Callback'] = function(e)
                C['Notifications']['Send']('Auto DC', ui['get'](e))
            end
        },
        ['Start Ping'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Discord Ping [match start]'),
            ['Callback'] = function(e)
                local bool = ui['get'](e)

                local base = C['DB']['Ping']
                local cmdBase = C['ConCmd']['Cmds']

                if (database['read'](base['ID']) == nil or database['read'](base['Webhook']) == nil) then
                    C['Notifications']['Send']('Error', not bool, 'You must set a discord id & webhook to use this.', 'err')

                    if (database['read'](base['ID']) == nil) then
                        C['Notifications']['Send']('', not bool, 'Type ' .. cmdBase['id']['Usage'] .. ' in the console.', 'err')
                    end

                    if (database['read'](base['Webhook']) == nil) then
                        C['Notifications']['Send']('', not bool, 'Type cyrus_webhook ' .. cmdBase['webhook']['Usage'] .. ' in the console.', 'err')
                    end

                    ui['set'](e, false)
                else
                    C['Notifications']['Send']('Discord Match Start Ping', bool)
                end
            end
        },
        ['End Ping'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Discord Ping [match end]'),
            ['Callback'] = function(e)
                local bool = ui['get'](e)

                local base = C['DB']['Ping']
                local cmdBase = C['ConCmd']['Cmds']

                if (database['read'](base['ID']) == nil or database['read'](base['WebhookEnd']) == nil) then
                    C['Notifications']['Send']('Error', not bool, 'You must set a discord id & webhook to use this.', 'err')

                    if (database['read'](base['ID']) == nil) then
                        C['Notifications']['Send']('', not bool, 'Type ' .. cmdBase['id']['Usage'] .. ' in the console.', 'err')
                    end

                    if (database['read'](base['WebhookEnd']) == nil) then
                        C['Notifications']['Send']('', not bool, 'Type cyrus_webhook_end ' .. cmdBase['webhook_end']['Usage'] .. ' in the console.', 'err')
                    end

                    ui['set'](e, false)
                else
                    C['Notifications']['Send']('Discord Match End Message', bool)
                end
            end
        }
    },
    ['Spam'] = {
        ['Type'] = {
            ['Element'] = ui['new_combobox'](C['Config']['Panel'], C['Config']['Side'], 'Spam Type', {'-', 'Kill', 'Death', 'Chat'}),
            ['Hidden'] = {
                ['Messages'] = {
                    ['Element'] = ui['new_combobox'](C['Config']['Panel'], C['Config']['Side'], 'Message', {'Off', 'Insult', 'Insult (Caps)', 'Cancer Strike', 'Super Cancer Strike', 'Annoying Question'}),
                    ['Callback'] = function(e)
                        local base = C['UI']['Spam']['Type']
                        local type = ui['get'](base['Element'])
                        local msg = ui['get'](base['Hidden']['Messages']['Element'])
                        local chatBase = C['Chat']['Spam']['Types']

                        local bool = (msg == 'Off')

                        if (chatBase[type] ~= msg) then
                            if (bool) then
                                C['Notifications']['Send'](type .. ' Say', not bool)
                            else
                                C['Notifications']['Send'](type .. ' Say', not bool, msg)
                            end
                        end

                        if (type ~= '-') then
                            chatBase[type] = msg
                        end
                    end
                },
                ['Speed'] = ui['new_slider'](C['Config']['Panel'], C['Config']['Side'], 'Spam Delay', 5, 150, 70, true, '%'),
            },
            ['Callback'] = function(e)
                local type = ui['get'](e)
                local bool = (type == '-')
                local base = C['UI']['Spam']['Type']['Hidden']
                local msgs = base['Messages']['Element']
                local speed = base['Speed']

                if (bool) then
                    ui['set_visible'](msgs, not bool)
                    ui['set_visible'](speed, type == 'Chat')
                else
                    ui['set_visible'](speed, type == 'Chat')
                    ui['set_visible'](msgs, not bool)

                    ui['set'](msgs, C['Chat']['Spam']['Types'][ ui['get'](C['UI']['Spam']['Type']['Element']) ])
                end
            end
        },
        ['ShitPostList'] = {
            ['Element'] = ui['new_combobox'](C['Config']['Panel'], C['Config']['Side'], 'Shitpost List', {'Insult', 'Insult (Caps)', 'Cancer Strike', 'Super Cancer Strike', 'Annoying Question'}),
            ['Callback'] = function(e)
                local type = ui['get'](e)
                C['Notifications']['Send']('Shit Post', true, type)
            end 
        },
        ['Execute'] = {
            ['Element'] = ui['new_button'](C['Config']['Panel'], C['Config']['Side'], 'Execute Shitpost', function(e) return end),
            ['Callback'] = function(e)
                local base = C['Funcs']
                local spamType = ui['get']( C['UI']['Spam']['ShitPostList']['Element'])
                local msg = base['GetShitPost'](spamType)

                if (ui['get'](C['UI']['Other']['Translator']['Hidden']['Outgoing']['Element']) and not C['Vars']['Translator']['OnCD']) then
                   base['DoChatTranslation'](msg, false, true)
                else
                    local chatMode = base['GetChatMode']()
                    client['exec'](chatMode, msg)
                end
            end 
        }
    },
    ['MM'] = {
        ['AFK Buy-Drop'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'AFK Buy-Drop [!buy xx]'),
            ['Callback'] = function(e)
                C['Notifications']['Send']('AFK Buy-Drop', ui['get'](e))
            end
        },
        ['Damage Logs'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Damage Logs [against enemy team]'),
            ['Callback'] = function(e)
                C['Notifications']['Send']('Damage Logs', ui['get'](e))
            end
        },
        ['TD Notifier'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Team Damage Notifications [ur team only]'),
            ['Callback'] = function(e)
                C['Notifications']['Send']('Team Damage Notifier', ui['get'](e))
            end
        },
        ['Target Team'] = {
            ['Element'] = ui['new_combobox'](C['Config']['Panel'], C['Config']['Side'], 'Target Team [rank dump]', {'Enemy', 'Team', 'All'}),
            ['Callback'] = function(e)
                C['Notifications']['Send']('Target Team', true, ui['get'](e))
            end
        },
        ['Notification Type'] = {
            ['Element'] = ui['new_multiselect'](C['Config']['Panel'], C['Config']['Side'], 'Notification Type [rank dump]', {'Chat Print', 'Chat Msg', 'Party Chat'}),
            ['Callback'] = function(e)
                local msg = ''
                local col = C['Colours']
                local tab = ui['get'](e)

                if (#tab > 0) then
                    for _, v in pairs(tab) do
                        msg = msg .. col['Purple'] .. v .. col['White'] .. ', '
                    end

                    msg = msg:sub(1, #msg - 2)

                    C['Notifications']['Send']('Rank Notification', true, msg)
                end
            end
        },
        ['Rank Dump'] = {
            ['Element'] = ui['new_button'](C['Config']['Panel'], C['Config']['Side'], 'Dump Rank + Wins', function(e) return end),
            ['Callback'] = function(e)
                local players = 0
                local col = C['Colours']
                local funcs = C['Funcs']
                local hasValue = funcs['table.HasValue']
                local tab = ui['get'](C['UI']['MM']['Notification Type']['Element'])
                local targetTeam = ui['get'](C['UI']['MM']['Target Team']['Element'])
                local myTeam = funcs['GetTeam'](entity['get_local_player']())

                for i = 1, globals['maxplayers']() do
                    local team = funcs['GetTeam'](i)

                    if (funcs['IsConnected'](i)) then
                        if ((team == 2 or team == 3) and funcs['IsHuman'](i)) then
                            if (targetTeam == 'Enemy' and team ~= myTeam) or (targetTeam == 'Team' and team == myTeam) or (targetTeam == 'All') then
                                local nick = entity['get_player_name'](i)
                                local wins = funcs['GetCompWins'](i)
                                local rank = funcs['GetCompRank'](i)

                                local msg =  nick.. ' has ' .. wins .. ' wins (' .. rank .. ')'
                                local msg_chat = col['Gold'] .. nick .. col['White'] .. ' has ' .. col['Purple'] .. wins .. col['White'] .. ' wins (' .. col['Red'] .. rank .. col['White'] .. ')'

                                if (hasValue(tab,'Chat Msg')) then
                                    client['delay_call'](funcs['GetChatDelay'](players), function()
                                        client['exec'](funcs['GetChatMode'](), msg)
                                    end)
                                end

                                if (hasValue(tab, 'Chat Print')) then
                                    C['Notifications']['Send']('', true, msg_chat, 'rank')
                                end

                                if (hasValue(tab, 'Party Chat')) then
                                    msg = msg:gsub(' ', '  ')
                                    funcs['PartyChatSay'](msg)
                                end

                                players = players + 1
                            end
                        end
                    end
                end
            end 
        }
    },
    ['Other'] = {
        ['Translator'] = {
            ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Translator'),
            ['Hidden'] = {
                ['Incoming'] = {
                    ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Translate Incoming Messages', false),
                    ['Callback'] = function(e)
                        C['Notifications']['Send']('Translate Incoming Messages', ui['get'](e))
                    end
                },
                ['Outgoing'] = {
                    ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Translate Outgoing Messages', false),
                    ['Callback'] = function(e)
                        C['Notifications']['Send']('Translate Outgoing Messages', ui['get'](e))
                    end
                },
                ['ShowOGMsg'] = {
                    ['Element'] = ui['new_checkbox'](C['Config']['Panel'], C['Config']['Side'], 'Display OG messages [sent by you]', false),
                    ['Callback'] = function(e)
                        C['Notifications']['Send']('Display OG Messages', ui['get'](e))
                    end
                },
                ['lblLocal'] = ui['new_label'](C['Config']['Panel'], C['Config']['Side'], 'Local Language [yours]'),
                ['Local'] = ui['new_textbox'](C['Config']['Panel'], C['Config']['Side'], 'en'),
                ['lblSource'] = ui['new_label'](C['Config']['Panel'], C['Config']['Side'], 'From Language'),
                ['Source'] = ui['new_textbox'](C['Config']['Panel'], C['Config']['Side'], 'en'),
                ['lblTo'] = ui['new_label'](C['Config']['Panel'], C['Config']['Side'], 'To Language'),
                ['To'] = ui['new_textbox'](C['Config']['Panel'], C['Config']['Side'], 'ru')
            },
            ['Callback'] = function(e)
                local base = C['UI']['Other']['Translator']['Hidden']
                local get = ui['get']
                local bool = get(e)

                if (get(base['Local']) == '') then
                    ui['set'](base['Local'], 'en')
                end

                if (get(base['Source']) == '') then
                    ui['set'](base['Source'], 'auto')
                end

                if (get(base['To']) == '') then
                    ui['set'](base['To'], 'ru')
                end

                for _, v in pairs(base) do
                    if (type(v) ~= 'table') then
                        ui['set_visible'](v, bool)
                    end
                end

                ui['set_visible'](base['Incoming']['Element'], bool)
                ui['set_visible'](base['Outgoing']['Element'], bool)
                ui['set_visible'](base['ShowOGMsg']['Element'], bool)

                C['Notifications']['Send']('Translator', bool)
            end
        }
    }
}

C['Events'] = {
    ['run_command'] = {
        ['Func'] = function(e)
            if (C['Chat']['Spam']['Types']['Chat'] ~= 'Off') then
                if (globals['tickcount']() >= (C['Chat']['Spam']['LastChatMessage'] + ui['get'](C['UI']['Spam']['Type']['Hidden']['Speed']))) then
                    local spamType = C['Chat']['Spam']['Types']['Chat']
                    local funcs = C['Funcs']
                    local msg = funcs['GetShitPost'](spamType)

                    if (ui['get'](C['UI']['Other']['Translator']['Hidden']['Outgoing']['Element']) and not C['Vars']['Translator']['OnCD']) then
                        base['DoChatTranslation'](msg, false, true)
                    else
                        local chatMode = funcs['GetChatMode']()
                        client['exec'](chatMode, msg)
                    end
    
                    C['Chat']['Spam']['LastChatMessage'] = globals['tickcount']()
                end
            end

            if (ui['get'](C['UI']['Utilities']['Radio Spam']['Element'])) then
                if (globals['tickcount']() >= (C['Chat']['Spam']['LastRadioMessage'] + ui['get'](C['UI']['Utilities']['Radio Spam']['Hidden']['Speed']))) then
                    client['exec'](C['Chat']['Spam']['RadioMessage'])
    
                    C['Chat']['Spam']['LastRadioMessage'] = globals['tickcount']()
                end
            end

            if (ui['get'](C['UI']['Utilities']['Vote Revealer']['Element'])) then
                for team, vote in pairs(C['Votes']['OnGoingVotes']) do
                    if (entity['get_prop'](vote['controller'], 'm_iActiveIssueIndex') ~= vote['IssueIndex']) then
                        C['Votes']['OnGoingVotes'][team] = nil
                    end
                end
            end
        end
    },
    ['setup_command'] = {
        ['Func'] = function(cmd)
            if (ui['get'](C['UI']['Utilities']['Use Spam']['Element'])) then
                local base = C['Vars']['UseSpam']

                if (ui['get'](C['UI']['Utilities']['Use Spam']['Hidden']['Key'])) then
                    if (globals['tickcount']() >= (base['LastSwap'] + ui['get'](C['UI']['Utilities']['Use Spam']['Hidden']['Speed']))) then
                        base['LastSwap'] = globals['tickcount']()
                        cmd.in_use = base['Swap']
                        base['Swap'] = not base['Swap']
                    end
                end
            end
        end
    },
    ['player_death'] = {
        ['Func'] = function(e)
            if (e['userid'] and e['attacker']) then
                local attacker = client['userid_to_entindex'](e['attacker'])
                local victim = client['userid_to_entindex'](e['userid'])
                local base = C['UI']
                local me = entity['get_local_player']()

                if (C['Chat']['Spam']['Types']['Kill'] ~= 'Off' or C['Chat']['Spam']['Types']['Death'] ~= 'Off') then
                    local funcs = C['Funcs']
                    local chatMode = funcs['GetChatMode']()

                    if (C['Chat']['Spam']['Types']['Kill'] ~= 'Off' and attacker == me and entity['is_enemy'](victim)) then
                        local spamType = C['Chat']['Spam']['Types']['Kill']
                        local msg = funcs['GetShitPost'](spamType)

                        if (ui['get'](C['UI']['Other']['Translator']['Hidden']['Outgoing']['Element']) and not C['Vars']['Translator']['OnCD']) then
                            funcs['DoChatTranslation'](msg, false, true)
                        else
                            client['exec'](chatMode, msg)
                        end
                    end

                    if (C['Chat']['Spam']['Types']['Death'] ~= 'Off' and entity['is_enemy'](attacker) and victim == me) then
                        local spamType = C['Chat']['Spam']['Types']['Death']
                        local msg = funcs['GetShitPost'](spamType)

                        if (ui['get'](C['UI']['Other']['Translator']['Hidden']['Outgoing']['Element']) and not C['Vars']['Translator']['OnCD']) then
                            funcs['DoChatTranslation'](msg, false, true)
                        else
                            client['exec'](chatMode, msg)
                        end
                    end
                end

                if (ui['get'](base['MM']['TD Notifier']['Element'])) then
                    local getTeam = C['Funcs']['GetTeam']

                    if (getTeam(attacker) == getTeam(me) and getTeam(victim) == getTeam(me) and attacker ~= victim) then
                        local col = C['Colours']
                        local victimNick = col['Purple'] .. entity['get_player_name'](victim) .. col['White']
                        local attackerNick = col['LightGreen'] .. entity['get_player_name'](attacker) .. col['White']

                        local id = e['attacker']

                        if (C['Vars']['TeamKillData'][id] == nil) then
                            C['Vars']['TeamKillData'][id] = {['dmg'] = 0, ['kills'] = 0}
                        end

                        C['Vars']['TeamKillData'][id]['kills'] = C['Vars']['TeamKillData'][id]['kills'] + 1

                        C['Notifications']['Send']('TK ', not bool, attackerNick .. ' killed ' .. victimNick .. ' (' .. C['Vars']['TeamKillData'][id]['kills'] .. '/3)', 'tk')
                    end
                end
            end
        end
    },
    ['player_hurt'] = {
        ['Func'] = function(e)
            if (e['userid'] and e['attacker']) then
                local attacker = client['userid_to_entindex'](e['attacker'])
                local victim = client['userid_to_entindex'](e['userid'])
                local col = C['Colours']
                local me = entity['get_local_player']()
                local getTeam = C['Funcs']['GetTeam']

                if (ui['get'](C['UI']['MM']['TD Notifier']['Element'])) then
                    if (getTeam(attacker) == getTeam(me) and getTeam(victim) == getTeam(me) and attacker ~= victim) then
                        local dmgDealt = col['Red'] .. e['dmg_health'] .. col['White']
                        local victimNick = col['Purple'] .. entity['get_player_name'](victim) .. col['White']
                        local attackerNick = col['LightGreen'] .. entity['get_player_name'](attacker) .. col['White']
                        local id = e['attacker']

                        if (C['Vars']['TeamKillData'][id] == nil) then
                            C['Vars']['TeamKillData'][id] = {['dmg'] = 0, ['kills'] = 0}
                        end

                        C['Vars']['TeamKillData'][id]['dmg'] = C['Vars']['TeamKillData'][id]['dmg'] + e['dmg_health']

                        C['Notifications']['Send']('TK ', not bool, attackerNick .. ' hurt ' .. victimNick .. ' for ' .. dmgDealt .. ' (' .. C['Vars']['TeamKillData'][id]['dmg'] .. '/' .. cvar['mp_td_dmgtokick']:get_int() .. ')', 'tk')
                    end
                end

                if (ui['get'](C['UI']['MM']['Damage Logs']['Element']) and attacker == me and getTeam(me) ~= getTeam(victim)) then
                    local victimNick = entity['get_player_name'](victim)
                    local shot = C['Vars']['HitLog']['ShotInfo'][e['id']]
    
                    local msg = col['Gold'] .. victimNick .. col['White'] .. ' in: ' .. col['Purple'] .. C['Vars']['HitLog']['Hit Groups'][e['hitgroup']]
                    msg = msg .. col['White'] .. ' for: ' .. col['Green'] .. e['dmg_health'] .. col['White'] .. ' dmg (' .. col['Red'] .. e['health'] .. col['White'] .. ' hp remaining)'
    
                    C['Notifications']['Send'](col['White'] .. 'Hit: ', true, msg, 'hitlog')
                end
            end
        end
    },
    ['round_announce_match_start'] = {
        ['Func'] = function(e)
            C['Vars']['TeamKillData'] = {}

            if (ui['get'](C['UI']['Utilities']['Start Ping']['Element'])) then
                local map = globals['mapname']() .. [[\n\n]]
                local base = C['DB']['Ping']
                local teamInitials = C['Funcs']['GetTeamInitials']
                local pingPlyTbl = C['Funcs']['StartPlayerTable']
                
                local content = '<@' .. database['read'](base['ID']) .. [[> CS:GO Match Started\n\n]]
                content = content .. '**Map:** ' .. map
                content = content .. '**Your Team (' .. teamInitials(true) .. ')**' .. pingPlyTbl(true)
                content = content .. '**Enemy Team (' .. teamInitials(false) .. ')**' .. pingPlyTbl(false)
            
                panorama['loadstring']([[
                    $.AsyncWebRequest(']] .. database['read'](base['Webhook']) .. [[',
                    {
                        type: 'POST',
                        data: {
                            'content': ']] .. content .. [['
                        },
                        complete: function (data){
                        }
                    });
                ]])()
            end
        end
    },
    ['cs_win_panel_match'] = {
        ['Func'] = function(e)
            C['Vars']['TeamKillData'] = {}

            client.delay_call(1, function()
                if (ui['get'](C['UI']['Utilities']['End Ping']['Element'])) then
                    local map = globals['mapname']() .. [[\n\n]]
                    local base = C['DB']['Ping']
                    local teamInitials = C['Funcs']['GetTeamInitials']
                    local teamRounds = C['Funcs']['GetTeamRounds']
                    local pingPlyTbl = C['Funcs']['EndPlayerTable']
                    local gameScore = teamRounds(true) .. ':' .. teamRounds(false)

                    local content = [[CS:GO Match Finished\n\n]]
                    content = content .. '**Map:** ' .. map
                    content = content .. '**Score**: ' .. gameScore .. [[\n\n]]
                    content = content .. '**Your Team (' .. teamInitials(true) .. ')**' .. pingPlyTbl(true)
                    content = content .. '**Enemy Team (' .. teamInitials(false) .. ')**' .. pingPlyTbl(false)
                
                    panorama['loadstring']([[
                        
                        $.AsyncWebRequest(']] .. database['read'](base['WebhookEnd']) .. [[',
                        {
                            type: 'POST',
                            data: {
                                'content': ']] .. content .. [['
                            },
                            complete: function (data){
                            }
                        });
                    ]])()
                end

                if (ui['get'](C['UI']['Utilities']['Auto Leave']['Element'])) then
                    client['exec']('disconnect')
                end
            end)
        end
    },
    ['cs_game_disconnected'] = {
        ['Func'] = function(e)
            C['Vars']['TeamKillData'] = {}
        end
    },
    ['vote_options'] = {
        ['Func'] = function(e)
            C['Votes']['VoteOptions'] = {e.option1, e.option2, e.option3, e.option4, e.option5}
            for i =#C['Votes']['VoteOptions'], 1, -1 do
                if (C['Votes']['VoteOptions'][i] == '') then
                    table['remove'](C['Votes']['VoteOptions'], i)
                end
            end
        end
    },
    ['vote_cast'] = {
        ['Func'] = function(e)
            client['delay_call'](0.3, function()
                if (ui['get'](C['UI']['Utilities']['Vote Revealer']['Element'])) then
                    local team = e['team']
                    local base = C['Votes']

                    if (C['Votes']['VoteOptions']) then
                        local controller
                        local voteControllers = entity['get_all']('CVoteController')
            
                        for i = 1, #voteControllers do
                            if entity['get_prop'](voteControllers[i], 'm_iOnlyTeamToVote') == team then
                                controller = voteControllers[i]
                                break
                            end
                        end
            
                        if (controller) then
                            local ongoingVote = {
                                ['team'] = team,
                                ['options'] = C['Votes']['VoteOptions'],
                                ['controller'] = controller,
                                ['IssueIndex'] = entity['get_prop'](controller, 'm_iActiveIssueIndex'),
                                ['votes'] = {}
                            }
            
                            for i = 1, #C['Votes']['VoteOptions'] do
                                ongoingVote['votes'][C['Votes']['VoteOptions'][i]] = {}
                            end
            
                            ongoingVote['type'] = C['Votes']['IndicesNoteam'][ongoingVote['IssueIndex']]
                            
                            if (team ~= -1 and C['Votes']['IndicesTeam'][ongoingVote['IssueIndex']]) then
                                ongoingVote['type'] = C['Votes']['IndicesTeam'][ongoingVote['IssueIndex']]
                            end
            
                            C['Votes']['OnGoingVotes']['team'] = ongoingVote
                        end
            
                        C['Votes']['VoteOptions'] = nil
                    end

                    local ongoingVote = C['Votes']['OnGoingVotes']['team']
                    if (ongoingVote) then
                        local player = e['entityid']
                        local col = C['Colours']
            
                        local voteText = ongoingVote['options'][e['vote_option'] + 1]
                        local voteTextCol = (voteText == 'Yes' and col['Green'] .. 'Yes' .. col['White'] or col['Red'] .. 'No' .. col['White'])
            
                        table['insert'](ongoingVote['votes'][voteText], player)

                        local colToUse = (team == 3 and col['Blue'] or col['LightYellow'])

                        if (voteText == 'Yes' and ongoingVote['caller'] == nil) then
                            ongoingVote['caller'] = player

                            if (ongoingVote['type'] ~= 'kick') then
                                local msg = col['White'] .. ' - ' .. colToUse .. entity['get_player_name'](player) .. col['White'] .. ' called a vote to ' .. col['Purple'] .. C['Votes']['Descriptions'][ongoingVote['type']] .. col['White']
        
                                C['Notifications']['Send']('Vote', false, msg, 'vote')
                            end
                        end

                        if (ongoingVote['type'] == 'kick') then
                            if (voteText == 'No') then
                                if (ongoingVote['target'] == nil) then
                                    ongoingVote['target'] = player

                                    local teamName = 'The ' .. (team == 3 and 'CT\'s' or 'T\'s') .. col['White']

                                    local msg = col['White'] .. ' - ' .. col['White'] .. colToUse .. teamName .. ' called a vote to ' .. col['Purple'] .. C['Votes']['Descriptions'][ongoingVote['type']] .. ' ' .. colToUse .. entity['get_player_name'](ongoingVote['target']) .. col['White']
        
                                    C['Notifications']['Send']('Vote', false, msg, 'vote')
                                end
                            end
                        end

                        local msg = col['White'] .. ' - ' .. colToUse .. entity['get_player_name'](player) .. col['White'] .. ' voted ' .. voteTextCol
                        C['Notifications']['Send']('Vote', false, msg, 'vote')
            
                    end
                end
            end)
        end
    },
    ['aim_fire'] = {
        ['Func'] = function(e)
            C['Vars']['HitLog']['ShotInfo'][e['id']] = e
        end
    },
    ['aim_hit'] = {
        ['Func'] = function(e)
            C['Vars']['HitLog']['Hit'][e['target']] = e['id']
        end
    },
    ['aim_miss'] = {
        ['Func'] = function(e)
            if (ui['get'](C['UI']['MM']['Damage Logs']['Element'])) then
                local target = e['target']
                local nick = entity['get_player_name'](target)
                local shot = C['Vars']['HitLog']['ShotInfo'][e['id']]
                local col = C['Colours']

                local white = col['White']

                local msg = col['Gold'] .. nick .. white .. '\'s ' .. col['Purple'] .. C['Vars']['HitLog']['Hit Groups'][shot['hitgroup']]
                msg = msg .. white .. ' (R: ' .. col['LightGreen'] .. e['reason'] .. white .. ', HC: ' .. col['LightRed'] .. math['floor'](shot['hit_chance'])
                msg = msg .. white .. ', Damage: ' .. col['LightRed'] .. shot['damage'] .. white .. ')'

                C['Notifications']['Send'](white .. 'Missed: ', true, msg, 'hitlog')
            end
        end
    },
    ['player_chat'] = {
        ['Func'] = function(e)
            local speaker = e['entity']
            local speakerTeam =  C['Funcs']['GetTeam'](speaker)
            local me = entity['get_local_player']()
            local myTeam =  C['Funcs']['GetTeam'](me)
            local text = e['text']

            if (ui['get'](C['UI']['MM']['AFK Buy-Drop']['Element'])) then
                local prefix = C['Chat']['CmdPrefix']

                if (text:sub(1,#prefix) == prefix) then
                    text = C['Funcs']['string.Explode'](' ', text)
                    local cmd = text[1]:sub(#prefix + 1, #text[1])

                    if (C['Funcs']['IsValidChatCmd'](cmd)) then
                        text[1] = nil
                        C['Chat']['Commands'][cmd]['Func'](text, speaker)
                    end
                end
            end

            if (ui['get'](C['UI']['Other']['Translator']['Element']) and not C['Vars']['Translator']['OnCD'] and speaker ~= me) then
                C['Funcs']['DoChatTranslation'](text, true, speaker == me)
            end
        end
    },
    ['weapon_fire'] = {
        ['Func'] = function(e)
            if (ui['get'](C['UI']['Utilities']['Plasma Shot']['Element'])) then
                local me = entity['get_local_player']()
                local shooter = client['userid_to_entindex'](e['userid'])

                if (C['Funcs']['HasTaser'](me) and ui['get'](C['UI']['Utilities']['Plasma Shot']['Hidden']['Key'])) then
                    if (shooter == me) then
                        local cmd = client['exec']

                        cmd('use weapon_taser')

                        client['delay_call'](C['Funcs']['GetChatDelay'](0.001), function()
                            cmd('lastinv')
                        end)

                    end
                end
            end
        end
    },
    ['console_input'] = {
        ['Func'] = function(text)
            if (text:sub(1, 5) == 'cyrus') then
                text = C['Funcs']['string.Explode'](' ', text)
                local cmd = text[1]:sub(#'cyrus_' + 1, #text[1])

                if (C['Funcs']['IsValidConsoleCmd'](cmd)) then
                    text[1] = nil
                    C['ConCmd']['Cmds'][cmd]['Func'](text)
                    return true
                else
                    C['Notifications']['ConsoleLog']('Invalid command entered, see cyrus_help for list of commands.', true, '')
                end
            end
        end
    },
    ['string_cmd'] = {
        ['Func'] = function(e)
            local text = e['text']
            local message = text:sub(#'say "' + 1, #text - 1)

            if (ui['get'](C['UI']['Other']['Translator']['Element'])) then
                if (message:sub(1, #'.tsay ') == '.tsay ') then
                    local language = message:sub(#'.tsay ' + 1, string.find(message, ' ', #'.tsay ' + 1) - 1)
                    local translateMsg = message:sub(#('.tsay ' .. language) + 2, #message)

                    C['Funcs']['DoChatTranslation'](translateMsg, false, true, language)
                    return true
                end

                if (ui['get'](C['UI']['Other']['Translator']['Hidden']['Outgoing']['Element']) and not C['Vars']['Translator']['OnCD']) then
                    if (text:sub(1, 5) == 'say "' and text ~= 'say ""' and text ~= 'say " "') then
                        C['Funcs']['DoChatTranslation'](message, false, true)
                        return true
                    end
                end
            end
        end
    }
}

for event, entry in pairs(C['Events']) do
    client['set_event_callback'](event, entry['Func'])
end

for cat, entry in pairs(C['UI']) do
    for var, table in pairs(entry) do
        if (table['Hidden']) then
            for _, hidden in pairs(table['Hidden']) do
                if (type(hidden) == 'table') then
                    ui['set_callback'](hidden['Element'], hidden['Callback'])
                    ui['set_visible'](hidden['Element'], false)
                else
                    ui['set_visible'](hidden, false)
                end
            end
        end

        ui['set_callback'](table['Element'], table['Callback'])
    end
end

C['Funcs']['PrintChangelogs']()
