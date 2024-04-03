/*
Fonction qui, lorsque le button avec la classe unfollow-btn est cliquee, envoie un AJAX call
au endpoint unfollow qui lui soccupe de DELETE dans la BD le id passe dans le data-id.
Modification du bouton pour montrer a lutilisateur que lartiste a bel et bien ete unfollowed.
@param Button
@param event
*/
document.addEventListener('DOMContentLoaded', function() {
    var unfollowButtons = document.querySelectorAll('.unfollow-btn');
    unfollowButtons.forEach(function(button) {
        button.addEventListener('click', function(event) {
            event.preventDefault();
            var idArtiste = this.getAttribute('data-id');
            fetch('/unfollow', {
                method: 'POST',
                body: JSON.stringify({ id_artiste: idArtiste }),
                headers: {
                    'Content-Type': 'application/json',

                }
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Probleme fetch ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {

                   button.classList.remove('btn-primary');
                    button.classList.add('btn-danger');
                    button.innerText= 'Désabonner!';
                    button.disable();
                } else {
                    console.error('Unfollow failed:', data.error);
                    alert('Failed to unfollow: ' + data.error);
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
        });
    });
});