local Essentia = require 'modules.infusion.core.entities.essentia'
describe('Essentia entity', function()
    local namedAspectsEssentia = Essentia.new({
        { name = 'Ordo', amount = 10 },
        { name = 'Perditio', amount = 32 }
    })
    local labeledAspectsEssentia = Essentia.new({
        { label = 'Ordo Gas', amount = 10 },
        { label = 'Perditio Gas', amount = 32 }
    })

    describe('creation', function()

        it('should create a new essentia from a of named aspects', function()
            assert.is_not_nil(namedAspectsEssentia)
        end)

        it('should create a new essentia from a list of labeled aspects', function()
            assert.is_not_nil(labeledAspectsEssentia)
        end)

        it('should create the same essentia from a list of labeled aspects as created from a list of named aspects',
           function()
            assert.is_same(namedAspectsEssentia, labeledAspectsEssentia)
        end)
    end)

    describe('printing', function()
        it('should print the essentia created from named aspects in a list', function()
            assert.is_same(tostring(namedAspectsEssentia), '\nOrdo Gas: 10\nPerditio Gas: 32')
        end)

        it('should print the essentia created from labeled aspects in a list', function()
            assert.is_same(tostring(labeledAspectsEssentia), '\nOrdo Gas: 10\nPerditio Gas: 32')
        end)
    end)

    describe('subtraction', function()
        it('should subtract essentia by name', function()
            local oneOrdoEssentia = Essentia.new({ { name = 'Ordo', amount = 1 } })
            local onePerditioEssentia = Essentia.new({ { name = 'Perditio', amount = 1 } })

            assert.is_same(
                namedAspectsEssentia - oneOrdoEssentia, {
                    { label = 'Ordo Gas', amount = 9 },
                    { label = 'Perditio Gas', amount = 32 }
                }
            )

            assert.is_same(
                namedAspectsEssentia - onePerditioEssentia,
                {
                    { label = 'Ordo Gas', amount = 10 },
                    { label = 'Perditio Gas', amount = 31 }
                }
            )
        end)

        it('should eliminate essentia from the list if it\'s amount is zero', function()
            assert.is_same(namedAspectsEssentia - labeledAspectsEssentia, {})
            assert.is_same(labeledAspectsEssentia - namedAspectsEssentia, {})
        end)

        it('should not yield negative essentia', function()
            local manyEssentia = Essentia.new({
                { name = 'Ordo', amount = 11 },
                { name = 'Perditio', amount = 33 }
            })

            assert.is_same(namedAspectsEssentia - manyEssentia, {})
        end)
    end)
end)
