window.onload = () => {
    // On va chercher toutes les étoiles
    const stars = document.querySelectorAll(".la-star");

    // On va chercher l'input
    const note = document.querySelector("#note");

    // On boucle sur les étoiles pour leur ajouter des écouteurs d'évènements
    for(star of stars){
        // On écoute le survol
        star.addEventListener("mouseover", function(){
            // Réinitialiser toutes les étoiles à leur couleur par défaut
            resetStars();
            // Changer la couleur de cette étoile et de celles précédentes en bleu
            this.style.color = "#1374FC";
            this.classList.add("las"); // Changer l'icône pleine
            this.classList.remove("lar"); // Retirer l'icône vide
            // L'élément précédent dans le DOM
            let previousStar = this.previousElementSibling;

            // Parcourir les étoiles précédentes et les changer en bleu
            while(previousStar){
                // Changer la couleur de l'étoile précédente en bleu
                previousStar.style.color = "#1374FC";
                previousStar.classList.add("las"); // Changer l'icône pleine
                previousStar.classList.remove("lar"); // Retirer l'icône vide
                // Passer à l'étoile précédente
                previousStar = previousStar.previousElementSibling;
            }
        });

        // On écoute le clic
        star.addEventListener("click", function(){
            // Mettre à jour la valeur de l'input avec la valeur de cette étoile
            note.value = this.dataset.value;
        });

        // On écoute lorsque la souris quitte l'étoile
        star.addEventListener("mouseout", function(){
            // Réinitialiser toutes les étoiles à leur couleur par défaut
            resetStars(note.value);
        });
    }

    // Fonction pour réinitialiser la couleur des étoiles
    function resetStars(note = 0){
        for(star of stars){
            // Si la valeur de l'étoile est supérieure à la note, la couleur est noire (étoile vide)
            if(star.dataset.value > note){
                star.style.color = "black";
                star.classList.add("lar"); // Ajouter l'icône vide
                star.classList.remove("las"); // Retirer l'icône pleine
            }else{
                // Sinon, la couleur est bleue (étoile pleine)
                star.style.color = "#1374FC";
                star.classList.add("las"); // Ajouter l'icône pleine
                star.classList.remove("lar"); // Retirer l'icône vide
            }
        }
    }
}
