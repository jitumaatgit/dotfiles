-- i will make any notes from this that is not specific to the code in file anki-nvim install note.md
return {
  "rareitems/anki.nvim",
  -- lazy -- don't lazy it, it tries to be as lazy possible and it needs to add a filetype association
  opts = {
    {
      -- this function will add support for associating '.anki' extension with both 'anki' and 'tex' filetype.
      tex_support = false,
      models = {
        -- Here you specify which notetype should be associated with which deck
        NoteType = "PathToDeck",
        ["Basic"] = "Deck",
        ["Super Basic"] = "Deck::ChildDeck",
      },
    },
  },
}
